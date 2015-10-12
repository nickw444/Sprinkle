from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.jobstores.sqlalchemy import SQLAlchemyJobStore
from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
from apscheduler.triggers.date import DateTrigger
from apscheduler.triggers.cron import CronTrigger
import pytz
import datetime
import arrow
import jsonrpclib

from sqlalchemy import create_engine
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
engine = create_engine('sqlite:///zones.db')
Base = declarative_base()
Session = sessionmaker(bind=engine)
class Zone(Base):
    __tablename__ = 'zone'
    circuit = Column(Integer, primary_key=True, autoincrement=False)
    _name = Column(String(255))

    @property
    def name(self):
        if self._name:
            return self._name
        else:
            return "Zone {}".format(self.circuit)
    @name.setter
    def name(self, other):
        self._name = other

Base.metadata.create_all(engine) 


jobstores = {
    'default': SQLAlchemyJobStore(url='sqlite:///jobs.sqlite')
}
executors = {
    'default': ThreadPoolExecutor(20),
}
job_defaults = {
    'coalesce': False,
    'max_instances': 3
}

scheduler = BackgroundScheduler(
    jobstores=jobstores, 
    executors=executors, 
    job_defaults=job_defaults, 
    timezone=pytz.UTC)
scheduler.start()

def delayed_off_runner(circuit, jobtype, value, state):
    set_mode(state, circuit)

def schedule_runner(circuit, jobtype, duration):
    print("Running scheduled task for circuit: {}".format(circuit))
    set_mode('ON',circuit=circuit, duration=duration)


# Enumerate Circuitstates by looking at the schedule.
# Circuits that are OFF will have disabled schd
# Circuits that are AUTO will have enabled schd
# Assume circuits with no schd are OFF.

from collections import defaultdict
circuit_off_times = defaultdict(lambda: None)
circuit_states = defaultdict(lambda: 'OFF')
jobs = filter(
    lambda x: x.kwargs['jobtype'] == 'scheduled',
    scheduler.get_jobs(),
)
for job in jobs:
    if job.next_run_time is None:
        # this job is disabled.
        circuit_states[job.kwargs['circuit']] = 'OFF'
    else:
        circuit_states[job.kwargs['circuit']] = 'AUTO'

print("Booted with circuit states: {}".format(circuit_states))



def jobs_for_circuit(circuit):
    return filter(
        lambda x: x.kwargs['circuit'] == circuit, 
        scheduler.get_jobs()
    )

def set_zones(num_zones):
    pass

def set_zone(circuit, zone_name):
    """
    Set the name of a circuit.
    """
    session = Session()
    rv = False
    try:
        db_zone = session.query(Zone).get(circuit)
        if not db_zone:
            db_zone = Zone(circuit=circuit)
            session.add(db_zone)
        db_zone.name = zone_name
        session.commit()
        rv = True
    except Exception as e:
        rv = False
        print(e)
    finally:
        session.close()

    return rv

def get_zone(zone, session=None):
    if session is None:
        _session = Session()
    else:
        _session = session


    mode = circuit_states[zone]
    off_at = None

    if circuit_off_times[zone] is not None:
        mode = 'ON'
        off_at = circuit_off_times[zone].isoformat()

    db_zone = _session.query(Zone).get(zone)
    if not db_zone:
        db_zone = Zone(circuit=zone)

    zone = dict(
        name=db_zone.name,
        mode=mode,
        off_at=off_at,
        circuit=zone,
    )

    if session is None:
        _session.close()

    return zone

def get_zones(zones=None):
    
    if zones is None:
        zones = range(8)

    session = Session()
    response = list()
    for x in zones:
        zone = get_zone(x, session=session)
        response.append(zone)

    session.close()

    print(response)

    return response


def get_mode(circuit):
    hwi = jsonrpclib.Server('http://raspberrypi:8001')
    state = None
    if hwi.get_port(circuit):
        state = 'ON'
    else:
        state = circuit_states[circuit]

    off_at = circuit_off_times[circuit]
    if off_at is not None:
        off_at = off_at.isoformat()
    return {
        'state': state,
        'off_at': off_at
    }


def set_mode(mode, circuit, duration=None):
    """
    Set the mode of a circuit to:
        - OFF : Off and Will not be triggered by schedule
        - ON : On and Will not be triggered by schedule
        - AUTO: Will be controlled by schedule. 

    OFF: 
        - Disable all future schd jobs for this circuit (pause_job)
        - Remove all future one-off jobs for this circuit
        - Turn off the circuit

    ON: 
        - Disable all future schd jobs for this circuit (pause_job)
        - Remove all future one-off jobs for this circuit
        - Turn on the circuit
        - Schedule the circuit to be turned off after duration
            - Additionally, return the circuit to either OFF or AUTO
              depending on previous state.

    AUTO:
        - Re-enable all future schd jobs for this circuit
        - Remove all future one-off jobs for this circuit
        - Turn off the circuit.
    """
    print("Turning circuit {} into mode {}".format(circuit, mode))
    jobs = jobs_for_circuit(circuit)
    hwi = jsonrpclib.Server('http://raspberrypi:8001')
    def clean_scheduled_and_one_off():
        for job in jobs:
            if job.kwargs['jobtype'] == 'scheduled':
                # Disable all future scheduled jobs
                print("Disabling job with id: {}".format(job.id))
                job.pause()

            elif job.kwargs['jobtype'] == 'one_off':
                # Remove all future one-off jobs for this circuit
                print("Removing job with id: {}".format(job.id))
                job.remove()

    if mode == 'OFF':
        clean_scheduled_and_one_off()

        circuit_off_times[circuit] = None
        hwi.set_port(circuit, 0)
        circuit_states[circuit] = 'OFF'

    elif mode == 'ON':
        clean_scheduled_and_one_off()
        hwi.set_port(circuit, 1)

        end_date = datetime.datetime.now(pytz.UTC) + datetime.timedelta(seconds=duration) 
        circuit_off_times[circuit] = end_date
        
        job = scheduler.add_job(
            delayed_off_runner,
            kwargs={
                'circuit': circuit,
                'jobtype': 'one_off',
                'value': 0,
                'state': circuit_states[circuit] # Previous state to resume to (AUTO/OFF)
            },
            name='oneoff',
            trigger=DateTrigger(run_date=end_date)
        )
        print("Created job with id: {} and args: {}".format(job.id, job.kwargs))

    elif mode =='AUTO':

        for job in jobs:
            if job.kwargs['jobtype'] == 'scheduled':
                # Disable all future scheduled jobs
                scheduler.resume_job(job.id)
            elif job.kwargs['jobtype'] == 'one_off':
                # Remove all future one-off jobs for this circuit
                scheduler.remove_job(job.id)

        circuit_off_times[circuit] = None
        circuit_states[circuit] = 'AUTO'
        hwi.set_port(circuit, 0)

    return get_zone(circuit)



def add_schedule(circuit, days, hour, minute, duration):
    """
    days (list): mon,tue,wed,thu,fri,sat,sun
    hour (int): 0-23
    minute (int): 0-59
    duration (int): Seconds to stay on for.
    """
    trigger = CronTrigger(day_of_week=days, hour=hour, minute=minute, second=0)
    job = scheduler.add_job(
        schedule_runner,
        kwargs={
            'circuit': circuit,
            'jobtype': 'scheduled',
            'duration': duration
        },
        name='scheduled',
        trigger=trigger
    )
    print("Created job with id: {} and args: {}".format(job.id, job.kwargs))
    set_mode('AUTO', circuit)

def get_schedule(circuit=None):
    response = []
    for job in scheduler.get_jobs():
        if circuit is None or job.kwargs['circuit'] == circuit:
            cron = dict()
            for f in job.trigger.fields:
                if f.name == 'day_of_week':
                    cron['day_of_week'] = str(f)
                elif f.name == 'hour':
                    cron['hour'] = str(f)
                elif f.name == 'minute':
                    cron['minute'] = str(f)

            s = dict(
                id=job.id,
                schedule=cron,
                duration=job.kwargs['duration'],
                circuit=job.kwargs['circuit'],
            )
            response.append(s)

    return response

def rm_schedule(job_id):
    scheduler.remove_job(job_id)


if __name__ == '__main__':
    from jsonrpclib.SimpleJSONRPCServer import SimpleJSONRPCServer
    import sys

    hostname = '127.0.0.1'
    port = 8002
    if '-h' in sys.argv:
        hostname = sys.argv[sys.argv.index('-h') + 1]

    if '-p' in sys.argv:
        port = int(sys.argv[sys.argv.index('-p') + 1])


    s = SimpleJSONRPCServer((hostname, port))
    s.register_function(set_mode)
    s.register_function(get_mode)
    s.register_function(add_schedule)
    s.register_function(get_schedule)
    s.register_function(rm_schedule)
    s.register_function(get_zones)
    s.register_function(set_zones)
    s.register_function(set_zone)
    s.serve_forever()


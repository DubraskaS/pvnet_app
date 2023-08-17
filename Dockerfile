FROM python:3.10-slim

ARG TESTING=0

# make sure it doesnt fail if the docker file doesnt know the git commit
ARG GIT_PYTHON_REFRESH=quiet

RUN apt-get update
RUN apt-get install git -y
RUN apt-get install g++ gcc libgeos++-dev libproj-dev proj-data proj-bin -y

# copy files
COPY setup.py app/setup.py
COPY README.md app/README.md
COPY requirements.txt app/requirements.txt
RUN pip install git+https://github.com/SheffieldSolar/PV_Live-API#pvlive_api


# install requirements
RUN pip install torch --index-url https://download.pytorch.org/whl/cpu
RUN pip install -r app/requirements.txt

# copy library files
COPY pvnet_app/ app/pvnet_app/
COPY tests/ app/tests/
COPY configs/ app/configs/
COPY scripts/ app/scripts/

# change to app folder
WORKDIR /app

# install library
RUN pip install -e .

# download models so app can used cached
RUN python scripts/cache_default_models.py


RUN if [ "$TESTING" = 1 ]; then pip install pytest pytest-cov coverage; fi

CMD ["python", "-u","pvnet_app/app.py"]
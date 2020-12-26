FROM TODO:cross-check/backend

COPY data/application.production.conf /application.production.conf
COPY ./migrate_and_run.sh /migrate_and_run.sh

RUN chmod +x ./migrate_and_run.sh

CMD ["./migrate_and_run.sh"]

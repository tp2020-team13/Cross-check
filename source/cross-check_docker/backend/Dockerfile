FROM stucrosscheck/backend:v2.3.3

COPY config/application.conf /application.conf
COPY ./migrate_and_run.sh /migrate_and_run.sh

RUN chmod +x ./migrate_and_run.sh

CMD ["./migrate_and_run.sh"]

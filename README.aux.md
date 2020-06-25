# GitLab Auxiliary Services

There are a number of non-essential services in GitLab that you can also run via the GCK.

These are:

- jaeger (distributed tracing)
- pgadmin (PostgreSQL management tool)
- Prometheus (and metrics exporters)

The service definitions for these have moved to `docker-compose.aux.yml` to clearly
separate them from essential services.

## Use Jaeger / OpenTracing

GitLab Compose Kit supports Jaeger integration that allows to see a correlation
of all events as part of [Tracing](https://docs.gitlab.com/ee/user/project/operations/tracing.html).

To use Tracing, you have to enable it for a moment, or forever:

```bash
# forever, by adding to gck.env
export USE_TRACING=jaeger >> gck.env

# for a moment
make web USE_TRACING=jaeger
```

Open [Performance Bar](https://docs.gitlab.com/ee/administration/monitoring/performance/performance_bar.html) or open Jaeger UI: https://localhost:16686.

## Use Prometheus

At GitLab we have started to productize Prometheus by bundling it with the app, which allows
us to self-monitor GitLab at various levels. If you need to test features that rely on a
running Prometheus instance, such as GitLab Self-Monitoring or Usage Ping, you can set up
and run a local Prometheus as per the instructions below. Prometheus will scrape all metrics
from running components as specified in `scape_configs`.

### Enable Prometheus

For the GitLab application to recognize that Prometheus is running, you need to enable it
via the `gitlab.yml` settings file. This file is managed by the GCK and rewritten frequently,
so to make the necessary changes, edit `gck.yml` as follows:

```yaml
gitlab.yml:
  development:
    prometheus:
      enable: true
      listen_address: prometheus:9090
```

This will ensure that the application is aware that a local Prometheus is running and where
to reach it.

### Run Prometheus

The Prometheus compose service is readily configured. You can start it as you would any other service:

```bash
$ make up-prometheus
```

Or in the foreground:

```bash
$ make prometheus
```

It will bind port `:9090` on the host machine, so you should be able to reach its frontend by navigating
to `localhost:9090` in your browser.

### Metrics Tokens

In some cicumstances you may need a `METRICS_TOKEN` in order to scrape metrics. To configure Prometheus
with a `METRICS_TOKEN`:

1. Start GitLab,
2. Go to http://localhost:3000/admin/health_check (or any other relevant URL),
3. Get `METRICS_TOKEN` and write it to `gck.env`: `export METRICS_TOKEN=3i113EJN5zf4Ng7Nm-mg >> gck.env`,
4. Run Prometheus (see above).

### Recording rules

Most of the configuration is hard-coded in the service definition in `docker-compose.aux.yml`. However,
we added support for defining custom recording rules. Any `*.rules` files you create in `<gck_home>/data/prometheus/rules`
will be ingested by Prometheus. You can see your rules e.g. by navigating to `http://localhost:9090/new/rules`.

### Node Exporter

Some monitoring features require data exported from `node_exporter`, which exports host machine metrics.
This is unfortunately difficult to simulate in a containerized environment, where all containers are
connected over a network and are considered hosts, but actually run on the same physical host machine.

GCK arbitrarily runs a `node_exporter` that is bound to the `web` service / host, so that metrics it emits
will appear to have originated from the main Rails app node.

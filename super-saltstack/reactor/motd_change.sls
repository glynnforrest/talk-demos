# reactor files should be very small and render quickly, then
# delegate any real work.
# here we tell the orchestrate runner to load orch.push_motd_to_web.sls.
push_motd_to_web:
    runner.state.orchestrate:
        - mods: orch.push_motd_to_web
        - pillar:
            event_tag: {{ tag }}
            event_data: {{ data | json() }}

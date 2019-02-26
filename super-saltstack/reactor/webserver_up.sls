# reactor files should be very small and render quickly, then
# delegate any real work.
# here we tell the orchestrate runner to load orch.take_photo.sls.
take_picture:
    runner.state.orchestrate:
        - mods: orch.take_photo
        - pillar:
            event_tag: {{ tag }}
            event_data: {{ data | json() }}

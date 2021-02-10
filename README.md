convert_set_flow pipeline
======================

Usage
-----

See *USAGE* or run `nextflow run main.nf --help`


Singularity
-----------

If you are on Linux, we recommend using the Singularity container to run convert_set_flow

Use scilpy singularity


Docker
------
If you are on MacOS or Windows, we recommend using the Docker container to run convert_set_flow.

You can build docker image using this command:

`docker pull dockerhub/scilus/scilpy:1.1.0 .`

```
nextflow main.nf --root=/path_to_your_data/ -with-docker extractor_flow:latest -resume
```

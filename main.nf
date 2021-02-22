#!/usr/bin/env nextflow

params.root = false
params.help = false
params.debug = true


if(params.help) {
    usage = file("$baseDir/USAGE")
    print usage.text
    return
    }

if (params.root_set){
    if (params.root_tractoflow){
    log.info "Input: $params.root_set"
    log.info "Input: $params.root_tractoflow"

    in_bundles = Channel
      .fromFilePairs("$params.root_set/**/F__Surface_Enhanced_Tractography/*.fib",
                     size: -1) { it.parent.parent.name }

    in_reference = Channel
        .fromFilePairs("$params.root_tractoflow/**/DTI_Metrics/*fa.nii.gz",
                       size: 1, flat: true) { it.parent.parent.name }
    }
    else {
          error "Error ~ Please use --root_tractoflow for the input data."
    }
}
else {
    error "Error ~ Please use --root_set for the input data."
}

in_bundles
    .flatMap{ sid, bundles -> bundles.collect{ [sid, it.getBaseName(), it] } }
    .set{bundles_to_combine}


in_reference.combine(bundles_to_combine, by: 0).set{data_ready}

process clean_trk {
  cpus 1
  memory '4 GB'

  input:
    set sid, file(reference), val(basename), file(tractogram)  from data_ready

  output:
    set sid, "${basename}__ic.trk"
    set sid, "${basename}__ic_no_loop.trk" into data_to_concatenate

  script:
  """
    scil_remove_invalid_streamlines.py ${tractogram} ${basename}__ic.trk \
    					     --remove_single_point \
      					   --remove_overlapping_points \
      					   --reference ${reference} -f

    scil_detect_streamlines_loops.py ${basename}__ic.trk \
    					 ${basename}__ic_no_loop.trk -a 330 -f
  """
}

data_to_concatenate.groupTuple(by: 0).set{data_input}

process concatenate_trk {
  cpus 1
  memory '10 GB'

  input:
    set sid, file(tractogram) from data_input

  output:
    set sid, "${sid}__set_merged_ic_noloop.trk"

  script:
  """
    scil_streamlines_math.py lazy_concatenate ${tractogram} \
      ${sid}__set_merged_ic_noloop.trk  -f
  """
}

include { TEST } from '../modules/test'

workflow TEST_WORKFLOW {
    take:
    srt_assembly

    main:
    
    TEST(srt_assembly)
}
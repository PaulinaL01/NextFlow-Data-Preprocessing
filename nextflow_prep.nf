#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.input = 'cnvnator/wgs_S4389Nr*'

input_ch = Channel.fromPath(params.input, checkIfExists: true)

workflow {

    
    delecje_proces(input_ch)


    duplikacje_proces(input_ch)

    delecje_kolumny(delecje_proces.out.delecje)

    duplikacje_kolumny(duplikacje_proces.out.duplikacje)

    srednia_duplikacje(duplikacje_kolumny.out.duplikacje_wynik_kolumny,input_ch)

    srednia_delecje(delecje_kolumny.out.delecje_wynik_kolumny,input_ch)

}

process delecje_proces {
    

    input:
    path read

    output:
    path ("*"), emit: delecje


    script:
    """
    # Print reads
    printf '${read}\t'
    
    grep deletion ${read} | awk '{split(\$2,chr,/:/); split(chr[2],pos,/-/); print chr[1],pos[1],pos[2],\$3}' | grep -wv [X,Y] > out_del_1.txt
    
    """
}

process duplikacje_proces {
    input:
    path read

    output:
    path ("*"), emit: duplikacje

    script:
    """
    grep duplication ${read} | awk '{split(\$2,chr,/:/); split(chr[2],pos,/-/); print chr[1],pos[1],pos[2],\$3}' | grep -wv [X,Y] > out_dupl_1.txt
    """

}
process delecje_kolumny {
    input:
    path delecje

    output:
    path("*"), emit: delecje_wynik_kolumny

     script:
    """
    awk 'BEGIN{print "Chr begin end len"}\$1' ${delecje} > out_del.txt
    """
}

process duplikacje_kolumny {
    input:
    path duplikacje

    output:
    path("*"), emit: duplikacje_wynik_kolumny

     script:
    """
    awk 'BEGIN{print "Chr begin end len"}\$1' ${duplikacje} > out_del.txt
    """
}
process srednia_delecje {

    publishDir "cnvnator/results/srednia_del" , pattern: "*.txt",mode: 'copy'
    
    input:
    path delecje_wynik_kolumny
    path read

    output:
    path("*"), emit: srednia_del

     script:
    """
    awk '{ total += \$4; count++ } END { print total/count }' ${delecje_wynik_kolumny} > ${read}wyniki_del.txt
    """
}
process srednia_duplikacje {

    publishDir "cnvnator/results/srednia_dup" , pattern: "*.txt",mode: 'copy'

    input:
    path duplikacje_wynik_kolumny
    path read

    output:
    path ("*"), emit:srednia_dup

     script:
    """
    awk '{ total += \$4; count++ } END { print total/count }' ${duplikacje_wynik_kolumny} > ${read}wyniki_dup.txt
    """
}




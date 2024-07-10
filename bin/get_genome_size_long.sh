#!/bin/bash
if [[ -z "$GSIZE" ]]; then
    echo $GSIZE
    mkdir tmp_out
    kmc -sm -m8 -t4 -k21 -ci10 $LR tmp_out 2>&1 | tee kmc_log.txt
    BP=$(grep -i "No. of unique counted k-mers" kmc_log.txt | awk '{print $NF}')
    CALCGSIZE=$(printf "%.0f" ${BP})
    echo $CALCGSIZE > gsize.txt
else
    if [[ "$GSIZE" =~ ([0-9.]+)([mM]*) ]]; then
        VALUE="${BASH_REMATCH[1]}"
        UNIT="${BASH_REMATCH[2]}"
        
        case $UNIT in
            m|M)
                CALCGSIZE=$(echo "$VALUE * 1000000" | bc)
                ;;
            *)
                CALCGSIZE=$VALUE  # Default to assuming the value is already in bases
                ;;
        esac

        CALCGSIZE=$(printf "%.0f" ${CALCGSIZE})
        echo $CALCGSIZE > gsize.txt
    else
        echo "Invalid GSIZE format: $GSIZE"
        exit 1
    fi
fi
for i in {1..10}
do
    name=ibmasim$i
    qsub -v id=$i $name RunSim.sh
done

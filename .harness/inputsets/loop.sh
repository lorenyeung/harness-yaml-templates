for i in {0..4500}; do
    echo $i
    cp goodexinputset.yaml goodexinputset$i.yaml
    sed -i '' 's/goodexample/goodexample'$i'/' goodexinputset$i.yaml
done

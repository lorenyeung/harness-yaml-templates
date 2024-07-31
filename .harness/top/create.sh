# todo; double loop through key list rather than hc
# l1: step/stepgroup/stage/pipeline
# l2: aws/gcp/utilities/mobile

mkdir -p step/aws stage/aws aws pipeline/aws stepgroup/aws
mkdir -p step/gcp stage/gcp gcp pipeline/gcp stepgroup/gcp

key1=step;key2=aws; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml
key1=stage;key2=aws; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml
key1=pipeline;key2=aws; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml
key1=stepgroup;key2=aws; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml

key1=stepgroup;key2=gcp; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml
key1=step;key2=gcp; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml
key1=stage;key2=gcp; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml
key1=pipeline;key2=gcp; echo "$key1-$key2" > $key1/$key2/template-$key1-$key2-v1.yaml

cp -r */aws/*.yaml aws/
cp -r */gcp/*.yaml gcp/

tree

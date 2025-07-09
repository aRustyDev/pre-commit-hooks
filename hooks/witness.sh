#!/usr/bin/env bash

# 1. Check for .witness.yaml file || create one
if [ ! -f .witness.yaml ]; then
  echo "witness.yaml file not found"
  echo "Creating example .witness.yaml file for you"
  echo "run 'witness help' for more information"
  cat << EOF > .witness.yaml
---
signer:
    timestampuri: https://tsa.sigstore.dev
    file:
        key: witness.key
        pub: witness.pub
        chain: witness.chain
    spiffe: "" # socket path
    fulcio:
        url: https://fulcio.sigstore.dev
        oidc:
            clientid: ""
            issuer: ""
            redirecturi: ""
        token:
            raw: ""
            path: ""
    kms:
        aws:
            config: witness-kms-config.json
            creds: witness-kms-config.json
            insecure: false
            profile: ""
            remote-verify: false
        gcp:
            creds: witness-kms-config.json
        hashType: SHA256
        keyVersion: ""
        ref: ""
    vault:
        alt: ""
        common: ""
        namespace: ""
        pki-secrets: ""
        role: ""
        token: ""
        ttl: ""
        url: ""
attestors:
    archivista: ""
    maven: ""
    slsa: true
    sbom: true
    hashes:
        - SHA256
verifier:
    kms:
        aws:
            config: witness-kms-config.json
            creds: witness-kms-config.json
            insecure: false
            profile: ""
            remote-verify: false
        gcp:
            creds: witness-kms-config.json
        hashType: SHA256
        keyVersion: ""
        ref: ""
run:
    signer:
        file: witness.key
        maven: witness.pom.xml
    trace: false
    out: ""
verify:
    attestor:
        type: slsa
        value: ""
    attestations:
        - "test-att.json"
    policy:
        file: policy-signed.json
        ca:
            file: witness.pem
            chain: witness.chain
            root: witness.root
        common: ""
        dns:
            - witness.dev
        emails:
            - ""
        fulcio:
            build-trigger: ""
            oidc-issuer: ""
            run-invocation-uri: ""
            source-repo:
                digest: ""
                identifier: ""
                ref: ""
        orgs:
            - ""
        timestampuris:
            - https://tsa.sigstore.dev
        uris:
            - ""
    publickey: witness.pub
EOF
  exit 1
fi

# 2. Check for witness binary
if ! command -v witness > /dev/null 2>&1; then
  echo "witness binary not found"
  echo "Downloading witness binary"
  go install/get "github.com/in-toto/witness/cmd/${ARCH:-}/witness@latest"
fi
if ! command -v yq > /dev/null 2>&1; then
  echo "yq binary not found"
  echo "Downloading yq binary"
  go install github.com/mikefarah/yq/v4@latest
fi
if ! command -v jq > /dev/null 2>&1; then
  echo "jq binary not found"
  echo "Download jq binary as per your OS"
  echo "- https://jqlang.github.io/jq/"
  exit 1
fi

# 3. Check Key Pair

while getopts ":r:a:s:" opt; do
  case $opt in
    r)
      witness_run="$OPTARG"
      ;;
    a)
      witness_run_args="$OPTARG"
      ;;
    s)
      # Step option reserved for future use
      :
      ;;
    \?)
      echo "Invalid option -$OPTARG" >&2
      exit 1
      ;;
  esac

  case $OPTARG in
    -*)
      echo "Option $opt needs a valid argument"
      exit 1
      ;;
  esac
done

if [ ! -f "$(yq eval '.run.signer-file-key-path' .witness.yaml)" ]; then
  echo "Private Key file in '.witness.yaml' not found"
  exit 1
fi
if [ ! -f "$(yq eval '.verify.publickey' .witness.yaml)" ]; then
  echo "Public Key file in '.witness.yaml' not found"
  exit 1
fi

# 4. Run witness
for i in $(yq eval '.verify.attestations[]' .witness.yaml); do
  if [ ! -f "$i" ]; then
    echo "Attestation file ($i) specified in '.witness.yaml' not found"
    exit 1
  fi
  witness run --step build -o "$i" -a slsa --attestor-slsa-export -- "$witness_run" "$witness_run_args" .
  jq -r .payload < "$i" | base64 -d | jq
done

# 5.View Attestation data in the signed DSSE envelope

# 6. check for/create policy file
if [ ! -f "$(yq eval '.verify.policy' .witness.yaml)" ]; then
  echo "Policy file in '.witness.yaml' not found"
  exit 1
fi

## policy.json

# {
#   "expires": "2023-12-17T23:57:40-05:00",
#   "steps": {
#     "build": {
#       "name": "build",
#       "attestations": [
#         {
#           "type": "https://witness.dev/attestations/material/v0.1",
#           "regopolicies": []
#         },
#         {
#           "type": "https://witness.dev/attestations/command-run/v0.1",
#           "regopolicies": []
#         },
#         {
#           "type": "https://witness.dev/attestations/product/v0.1",
#           "regopolicies": []
#         }
#       ],
#       "functionaries": [
#         {
#           "publickeyid": "{{PUBLIC_KEY_ID}}"
#         }
#       ]
#     }
#   },
#   "publickeys": {
#     "{{PUBLIC_KEY_ID}}": {
#       "keyid": "{{PUBLIC_KEY_ID}}",
#       "key": "{{B64_PUBLIC_KEY}}"
#     }
#   }
# }

# 7. Replace variables in the policy
id=$(sha256sum testpub.pem | awk '{print $1}') && sed -i "s/{{PUBLIC_KEY_ID}}/$id/g" policy.json
pubb64=$(base64 -w 0 < testpub.pem) && sed -i "s/{{B64_PUBLIC_KEY}}/$pubb64/g" policy.json

# 8. Sign the policy file
witness sign -f policy.json --signer-file-key-path testkey.pem --outfile policy-signed.json

# 9. Verify the binary against the policy
witness verify -f testapp -a test-att.json -p policy-signed.json -k testpub.pem

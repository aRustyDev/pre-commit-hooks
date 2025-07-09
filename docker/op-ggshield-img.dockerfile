FROM gitguardian/ggshield as gg
FROM 1password/op as op
FROM scratch as final

COPY --from=gg /ggshield /usr/local/bin/ggshield
COPY --from=op /usr/local/bin/op /usr/local/bin/op
COPY . /src

ARG OP_VAULT
ARG OP_ITEM_NAME
ARG OP_ITEM_FIELD=credential

VOLUME [ "/src:rw,Z" ]

ENV GITGUARDIAN_API_KEY `op read op://${OP_VAULT}/${OP_ITEM_NAME}/${OP_ITEM_FIELD}`

ENTRYPOINT [ "op run --env='/src/op.env' -- ggshield secret scan pre-commit" ]

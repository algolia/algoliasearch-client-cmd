#! /bin/bash

HOST=""

usage() {
    echo "Usage: $0 (GET|POST|PUT|DELETE) /1/<ENDPOINT> [cURL arguments]"
    echo
    echo "Ex:"
    echo "     Test if the service is alive:"
    echo "       APPLICATION_ID=******** API_KEY=************************* $0 GET /1/isalive"
    echo "     Delete an index:"
    echo "       APPLICATION_ID=******** API_KEY=************************* $0 DELETE /1/indexes/myindextodelete"
    echo "     Set the settings of an index:"
    echo "       APPLICATION_ID=******** API_KEY=************************* $0 PUT /1/indexes/myindex/settings -d '{\"attributesToIndex\": [\"title\", \"description\"]}'"
    echo "     Search:"
    echo "       APPLICATION_ID=******** API_KEY=************************* $0 POST /1/indexes/myindex/query -d '{\"query\": \"test\"}'"
    echo
    echo
    exit 1
}

if [ -z "$APPLICATION_ID" ]; then
    echo "error: Please set your APPLICATION_ID environment variable."
    echo
    usage
fi
if [ -z "$API_KEY" ]; then
    echo "error: Please set your API_KEY environment variable."
    echo
    usage
fi

headers=(--header "Content-Type: application/json; charset=utf-8")
headers+=(--header "X-Algolia-Application-Id: $APPLICATION_ID")
headers+=(--header "X-Algolia-API-Key: $API_KEY")

method=
case $1 in
    POST)
        method="$1"
        ;;
    PUT)
        method="$1"
        ;;
    DELETE)
        method="$1"
        ;;
    GET)
        method="$1"
        ;;
    *)
        usage
        ;;
esac
shift

path=
case $1 in
    /*)
        path="$1"
        ;;
    *)
        usage
        ;;
esac
shift

request() {
if [ "$(uname)" == "Darwin" ]; then
    template=algolia
else
    template=algoliaXXX
fi

    stdout=`mktemp -t $template`
    stderr=`mktemp -t $template`
    code=0
    for domain in ".algolia.net" "-1.algolianet.com" "-2.algolianet.com" "-3.algolianet.com"; do
        url="https://$APPLICATION_ID$domain$path"
        curl --silent --show-error "${headers[@]}" --request $method "$url" "$@" > $stdout 2> $stderr
        code=$?
        if [ $code -eq 0 ]; then
            break
        fi
    done
    cat "$stdout"
    cat "$stderr" >&2
    rm "$stdout"
    rm "$stderr"
    exit $code
}

request "$@"

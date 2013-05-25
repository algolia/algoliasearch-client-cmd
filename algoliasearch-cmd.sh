#!/bin/bash
API_KEY="YourAPIKey"
APPLICATION_ID="YouApplicationID"
HOST="https://user-1.algolia.io"
GZIP=0
VERBOSE=0

usage() {
    echo "Usage:"
    echo "  List your indexes"
    echo "      $0 indexes"
    echo "  Query an index: "
    echo "      $0 query INDEXNAME QUERY [args]"
    echo "  Retrieve objects from the index:"
    echo "      $0 retrieve INDEXNAME [args]"
    echo "  Delete an index"
    echo "      $0 deleteIndex INDEXNAME"
    echo ""
    echo "  Add an object:"
    echo "      $0 add INDEXNAME OBJECT_FILENAME [objectID]"
    echo "  Get an object from the index:"
    echo "      $0 get INDEXNAME OBJECTID [args]"
    echo "  Replace an object in the index:"
    echo "      $0 replace INDEXNAME OBJECTID OBJECT_FILENAME [args]"
    echo "  Delete an objet in the index:"
    echo "      $0 delete INDEXNAME OBJECTID"
    echo "  Partial update an object in the index:"
    echo "      $0 partialUpdate INDEXNAME OBJECTID OBJECT_FILENAME [args]"
    echo ""
    echo "  Get settings"
    echo "      $0 getSettings INDEXNAME"
    echo "  Set settings"
    echo "      $0 changeSettings INDEXNAME SETTING_FILENAME"
    echo "  Get Task info"
    echo "      $0 task INDEXNAME TASKID"
    echo ""
    echo "  Batch requests"
    echo "      $0 batch INDEXNAME BATCH_FILENAME"
    echo ""
    echo "  Get lists of User defined API Keys"
    echo "      $0 getACL"
    echo "  Get lists details of one User defined API Key"
    echo "      $0 getACL keyName"
    echo "  Add one User defined API Key"
    echo "      $0 addACL ACL_FILENAME"
    echo "  Delete one User defined API Key"
    echo "      $0 delACL keyName"

    exit 1;
}
headers=(-k --header "Content-Type: application/json; charset=utf-8")
if [ "x$ALGOLIA_API_KEY" = "x" ]; then
  headers+=(--header "X-Algolia-API-Key: $API_KEY")
else
  headers+=(--header "X-Algolia-API-Key: $ALGOLIA_API_KEY")
fi
if [ "x$ALGOLIA_APPLICATION_ID" = "x" ]; then
  headers+=(--header "X-Algolia-Application-Id: $APPLICATION_ID")
else
  headers+=(--header "X-Algolia-Application-Id: $ALGOLIA_APPLICATION_ID")
fi
if [ "x$ALGOLIA_HOST" = "x" ]; then
  headers+=(--header "X-Algolia-Application-Id: $HOST")
else
  headers+=(--header "X-Algolia-Application-Id: $ALGOLIA_HOST")
fi
if [ "x$GZIP" = "x1" ]; then
    headers+=(--header "Accept-Encoding: gzip,deflate")
fi
if [ "x$VERBOSE" = "x1" ]; then
    headers+=(-w "\ntime_namelookup:     %{time_namelookup}\ntcp connect:         %{time_connect}\nssl done:            %{time_appconnect}\ntime_pretransfer:    %{time_pretransfer}\ntime_redirect:       %{time_redirect}\ntime_starttransfer:  %{time_starttransfer}\n---------------------------\ntime_total:          %{time_total}")
fi

case $1 in
    batch)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        curl "${headers[@]}" --request POST "$HOST/1/indexes/$2/batch" --data-binary @$3
        echo
        ;;
    indexes)
        curl "${headers[@]}" --request GET "$HOST/1/indexes"
        echo
        ;;
    delete)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        curl "${headers[@]}" --request DELETE "$HOST/1/indexes/$2/$3"
        echo
        ;;
    deleteIndex)
        if [ -z "$2" ]; then
            usage
        fi
        curl "${headers[@]}" --request DELETE "$HOST/1/indexes/$2"
        echo
        ;;
    changeSettings)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        curl "${headers[@]}" --request PUT "$HOST/1/indexes/$2/settings" --data-binary @$3
        echo
        ;;
    getACL)
        if [ -z "$2" ]; then
          curl "${headers[@]}" --request GET "$HOST/1/keys"
        else
          curl "${headers[@]}" --request GET "$HOST/1/keys/$2"
	fi
        echo
        ;;
    deleteACL)
        if [ -z "$2" ]; then
          usage
	fi
        curl "${headers[@]}" --request DELETE "$HOST/1/keys/$2"
        echo
        ;;
    addACL)
        if [ -z "$2" ]; then
          usage
	fi
        curl "${headers[@]}" --request POST "$HOST/1/keys" --data-binary @$2
        echo
        ;;

    task)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/task/$3"
        echo
        ;;
    getSettings)
        if [ -z "$2" ]; then
            usage
        fi
        curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/settings"
        echo
        ;;
    replace)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        if [ -z "$4" ]; then
            usage
        fi

        curl "${headers[@]}" --request PUT "$HOST/1/indexes/$2/$3" --data-binary @$4
        echo
        ;;
    partialUpdate)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        if [ -z "$4" ]; then
            usage
        fi

        curl "${headers[@]}" --request POST "$HOST/1/indexes/$2/$3/partial" --data-binary @$4
        echo
        ;;
    get)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        if [ -n "$4" ]; then
            curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/$3?$4"
        else
            curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/$3"
        fi
        echo
        ;;
    add)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        if [ -n "$4" ]; then
            curl "${headers[@]}" --request PUT "$HOST/1/indexes/$2/$4" --data-binary @$3 
        else
            curl "${headers[@]}" --request POST "$HOST/1/indexes/$2" --data-binary @$3
        fi
        echo
        ;;
    retrieve)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -n "$3" ]; then
            curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/?$3"
        else
            curl "${headers[@]}" --request GET "$HOST/1/indexes/$2"
        fi
        echo
        ;;
    query)
        if [ -z "$2" ]; then
            usage
        fi
        if [ -z "$3" ]; then
            usage
        fi
        if [ -n "$4" ]; then
            curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/?query=$3&$4"
        else
            curl "${headers[@]}" --request GET "$HOST/1/indexes/$2/?query=$3"
        fi
        echo
        ;;
    *)
        usage
        ;;
esac


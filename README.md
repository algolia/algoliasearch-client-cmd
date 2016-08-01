AlgoliaSearch REST API CLI Client
=================================

This API client has been done to ease the usage of Algolia's REST API from the command line. It's a [cURL](https://curl.haxx.se/docs/manpage.html) wrapper handling the retry strategy complexity for you.

# Usage

```
$ ./algoliasearch-cmd.sh (GET|POST|PUT|DELETE) /1/<ENDPOINT> [cURL arguments]
```

Examples:

  * Test if the service is alive:

    ```
    $ APPLICATION_ID=******** API_KEY=******** ./algoliasearch-cmd.sh GET /1/isalive
    ```

  * Delete an index:

    ```
    $ APPLICATION_ID=******** API_KEY=******** ./algoliasearch-cmd.sh DELETE /1/indexes/myindextodelete
    ```

  * Set the settings of an index:

    ```
    $ APPLICATION_ID=******** API_KEY=******** ./algoliasearch-cmd.sh PUT /1/indexes/myindex/settings -d '{"attributesToIndex": ["title", "description"]}'
    ```

  * Search:

    ```
    $ APPLICATION_ID=******** API_KEY=******** ./algoliasearch-cmd.sh POST /1/indexes/myindex/query -d '{"query": "test"}'
    ```


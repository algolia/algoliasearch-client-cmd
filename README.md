Algolia Search Command Line API Client
==================

[Algolia Search](http://www.algolia.com) is a search API that provides hosted full-text, numerical and faceted search.
Algolia’s Search API makes it easy to deliver a great search experience in your apps & websites providing:

 * REST and JSON-based API
 * search among infinite attributes from a single searchbox
 * instant-search after each keystroke
 * relevance & popularity combination
 * typo-tolerance in any language
 * faceting
 * 99.99% SLA
 * first-class data security

This command line API Client is a small wrapper around CURL to easily expose our API.

Table of Content
-------------
**Get started**

1. [Setup](#setup) 
1. [Quick Start](#quick-start)

**Commands reference**

1. [Search](#search)
1. [Add a new object](#add-a-new-object-in-the-index)
1. [Update an object](#update-an-existing-object-in-the-index)
1. [Get an object](#get-an-object)
1. [List indexes](#list-indexes)
1. [Delete an object](#delete-an-object)
1. [Index settings](#index-settings)
1. [Delete an index](#delete-an-index)
1. [Clear an index](#clear-an-index)
1. [Batch writes](#batch-writes)
1. [Security / User API Keys](#security--user-api-keys)
1. [Copy or rename an index](#copy-or-rename-an-index)
1. [Logs](#logs)

Setup
-------------
To setup the command line client,

 1. Download the [client](https://github.com/algolia/algoliasearch-client-cmd/archive/master.zip)
 2. Open `algoliasearch-cmd.sh` and change `API_KEY` and `APPLICATION_ID` with the values you can find in [your Algolia account](http://www.algolia.com/users/edit).

```sh
API_KEY="YourAPIKey"
APPLICATION_ID="YourApplicationID"
```

Quick Start
-------------
This quick start is a 30 seconds tutorial where you can discover how to index and search objects.


Without any prior-configuration, you can index [500 contacts](https://github.com/algolia/algoliasearch-client-cmd/blob/master/contacts.json) in the ```contacts``` index with the following code:
```sh
./algoliasearch-cmd.sh batch contacts contacts.json
```
The contacts.json file is formated in our [batch format](http://www.algolia.com/doc/rest_api#Batch). The ```body```attribute contains the user-object that can be any valid JSON.

You can then start to search for a contact firstname, lastname, company, ... (even with typos):
```sh
# search by firstname
./algoliasearch-cmd.sh query contacts "jimmie"
# search a firstname with typo
./algoliasearch-cmd.sh query contacts "jimie"
# search for a company
./algoliasearch-cmd.sh query contacts "california paint"
# search for a firstname & company
./algoliasearch-cmd.sh query contacts "jimmie paint"
```

Settings can be customized to tune the search behavior. For example you can add a custom sort by number of followers to the already good out-of-the-box relevance:
```sh
echo '{"customRanking": ["desc(followers)"]}' > settings-contacts-1.json
./algoliasearch-cmd.sh changeSettings contacts settings-contacts-1.json
```
You can also configure the list of attributes you want to index by order of importance (first = most important):
```sh
echo '{"attributesToIndex": ["lastname", "firstname", "company"]}' > settings-contacts-2.json
./algoliasearch-cmd.sh changeSettings contacts settings-contacts-2.json
```

Since the engine is designed to suggest results as you type, you'll generally search by prefix. In this case the order of attributes is very important to decide which hit is the best:
```sh
./algoliasearch-cmd.sh query contacts "or"
./algoliasearch-cmd.sh query contacts "jim"
```

Search
-------------
To perform a search, you have just to specify the index name and the query. 

This example perform the query `query string" on `contacts` index:

```sh
algoliasearch-cmd.sh query contacts "query string"
```

You can use the following optional arguments:
 * **page**: (integer) Pagination parameter used to select the page to retrieve.<br/>Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set `page=9`
 * **hitsPerPage**: (integer) Pagination parameter used to select the number of hits per page. Defaults to 20.
 * **attributesToRetrieve**: a string that contains the list of object attributes you want to retrieve (let you minimize the answer size).<br/> Attributes are separated with a comma (for example `"name,address"`), you can also use a string array encoding (for example `["name","address"]` ). By default, all attributes are retrieved. You can also use `*` to retrieve all values when an **attributesToRetrieve** setting is specified for your index.
 * **attributesToHighlight**: a string that contains the list of attributes you want to highlight according to the query. Attributes are separated by a comma. You can also use a string array encoding (for example `["name","address"]`). If an attribute has no match for the query, the raw value is returned. By default all indexed text attributes are highlighted. You can use `*` if you want to highlight all textual attributes. Numerical attributes are not highlighted. A matchLevel is returned for each highlighted attribute and can contain:
  * **full**: if all the query terms were found in the attribute,
  * **partial**: if only some of the query terms were found,
  * **none**: if none of the query terms were found.
 * **attributesToSnippet**: a string that contains the list of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`). Attributes are separated by a comma (Example: `attributesToSnippet=name:10,content:10`). <br/>You can also use a string array encoding (Example: `attributesToSnippet: ["name:10","content:10"]`). By default no snippet is computed.
 * **minWordSizefor1Typo**: the minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 3.
 * **minWordSizefor2Typos**: the minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 7.
 * **getRankingInfo**: if set to 1, the result hits will contain ranking information in **_rankingInfo** attribute.
 * **aroundLatLng**: search for entries around a given latitude/longitude (specified as two floats separated by a comma).<br/>For example `aroundLatLng=47.316669,5.016670`).<br/>You can specify the maximum distance in meters with the **aroundRadius** parameter (in meters) and the precision for ranking with **aroundPrecision** (for example if you set aroundPrecision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **insideBoundingBox**: search entries inside a given area defined by the two extreme points of a rectangle (defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).<br/>For example `insideBoundingBox=47.3165,4.9665,47.3424,5.0201`).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **numericFilters**: a string that contains the list of numeric filters you want to apply separated by a comma. The syntax of one filter is `attributeName` followed by `operand` followed by `value`. Supported operands are `<`, `<=`, `=`, `>` and `>=`. 
 You can have multiple conditions on one attribute like for example `numericFilters=price>100,price<1000`. You can also use a string array encoding (for example `numericFilters: ["price>100","price<1000"]`).
 * **tagFilters**: filter the query by a set of tags. You can AND tags by separating them by commas. To OR tags, you must add parentheses. For example, `tags=tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*. You can also use a string array encoding, for example `tagFilters: ["tag1",["tag2","tag3"]]` means *tag1 AND (tag2 OR tag3)*.<br/>At indexing, tags should be added in the **_tags** attribute of objects (for example `{"_tags":["tag1","tag2"]}`). 
 * **facetFilters**: filter the query by a list of facets. Facets are separated by commas and each facet is encoded as `attributeName:value`. For example: `facetFilters=category:Book,author:John%20Doe`. You can also use a string array encoding (for example `["category:Book","author:John%20Doe"]`).
 * **facets**: List of object attributes that you want to use for faceting. <br/>Attributes are separated with a comma (for example `"category,author"` ). You can also use a JSON string array encoding (for example `["category","author"]` ). Only attributes that have been added in **attributesForFaceting** index setting can be used in this parameter. You can also use `*` to perform faceting on all attributes specified in **attributesForFaceting**.
 * **queryType**: select how the query words are interpreted, it can be one of the following value:
  * **prefixAll**: all query words are interpreted as prefixes,
  * **prefixLast**: only the last word is interpreted as a prefix (default behavior),
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **optionalWords**: a string that contains the list of words that should be considered as optional when found in the query. The list of words is comma separated.

```sh
algoliasearch-cmd.sh query contacts "jimmie paint" "attributesToRetrieve=firstname,lastname&hitsPerPage=50"
```

The server response will look like:

```javascript
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "objectID": "433",
      "_highlightResult": {
        "firstname": {
          "value": "<em>Jimmie</em>",
          "matchLevel": "partial"
        },
        "lastname": {
          "value": "Barninger",
          "matchLevel": "none"
        },
        "company": {
          "value": "California <em>Paint</em> & Wlpaper Str",
          "matchLevel": "partial"
        }
      }
    }
  ],
  "page": 0,
  "nbHits": 1,
  "nbPages": 1,
  "hitsPerPage": 20,
  "processingTimeMS": 1,
  "query": "jimmie paint",
  "params": "query=jimmie+paint&attributesToRetrieve=firstname,lastname&hitsPerPage=50"
}
```

Add a new object in the Index
-------------

Each entry in an index has a unique identifier called `objectID`. You have two ways to add en entry in the index:

 1. Using automatic `objectID` assignement, you will be able to retrieve it in the answer.
 2. Passing your own `objectID`.

You don't need to explicitely create an index, it will be automatically created the first time you add an object.
Objects are schema less, you don't need any configuration to start indexing. The settings section provide details about advanced settings.

Example with automatic `objectID` assignement:

```sh
echo '{"firstname": "Jimmie", "lastname": "Barninger"}' > city.json
algoliasearch-cmd.sh add contacts city.json
```

Example with manual `objectID` assignement:

```javascript
echo '{"firstname": "Jimmie", "lastname": "Barninger"}' > city.json
algoliasearch-cmd.sh add contacts city.json myID
```


Update an existing object in the Index
-------------

You have two options to update an existing object:

 1. Replace all its attributes.
 2. Replace only some attributes.

Example to replace all the content of an existing object:

```sh
echo '{"firstname": "Jimmie", "lastname": "Barninger", "city":"New York"}' > city.json
algoliasearch-cmd.sh replace contacts myID ./city.json
```

Example to update only the city attribute of an existing object:

```javascript
echo '{"city": "San Francisco"}' > city.json
algoliasearch-cmd.sh partialUpdate contacts myID ./city.json
```

Get an object
-------------

You can easily retrieve an object using its `objectID` and optionnaly a list of attributes you want to retrieve (using comma as separator):

Retrieve all attributes:
```sh
algoliasearch-cmd.sh get contacts myID
```

Retrieve firstname and lastnae attributes of `myID` object and then only the firstname attribute:
```sh
algoliasearch-cmd.sh get contacts myID "attributes=firstname,lastname"
algoliasearch-cmd.sh get contacts myID "attributes=firstname"
```

Delete an object
-------------

You can delete an object using its `objectID`:

```sh
algoliasearch-cmd.sh delete contacts myID
```

Index Settings
-------------

You can retrieve all settings using the `settings` argument. The result will contains the following attributes:

 * **minWordSizefor1Typo**: (integer) the minimum number of characters to accept one typo (default = 3).
 * **minWordSizefor2Typos**: (integer) the minimum number of characters to accept two typos (default = 7).
 * **hitsPerPage**: (integer) the number of hits per page (default = 10).
 * **attributesToRetrieve**: (array of strings) default list of attributes to retrieve in objects. If set to null, all attributes are retrieved.
 * **attributesToHighlight**: (array of strings) default list of attributes to highlight. If set to null, all indexed attributes are highlighted.
 * **attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords')<br/>By default no snippet is computed. If set to null, no snippet is computed.
 * **attributesToIndex**: (array of strings) the list of fields you want to index.<br/>If set to null, all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results.<br/>This parameter has two important uses:
  * *Limit the attributes to index*.<br/>For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
  * *Control part of the ranking*.<br/>(see the ranking parameter for full explanation) Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable this behavior if you add your attribute inside `unordered(AttributeName)`, for example `attributesToIndex: ["title", "unordered(text)"]`.
 * **attributesForFaceting**: (array of strings) The list of fields you want to use for faceting. All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
 * **ranking**: (array of strings) controls the way results are sorted.<br/>We have six available criteria: 
  * **typo**: sort according to number of typos,
  * **geo**: sort according to decreassing distance when performing a geo-location based search,
  * **proximity**: sort according to the proximity of query words in hits,
  * **attribute**: sort according to the order of attributes defined by attributesToIndex,
  * **exact**: sort according to the number of words that are matched identical to query word (and not as a prefix),
  * **custom**: sort according to a user defined formula set in **customRanking** attribute.<br/>The standard order is ["typo", "geo", "proximity", "attribute", "exact", "custom"]
 * **customRanking**: (array of strings) lets you specify part of the ranking.<br/>The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
For example `"customRanking" => ["desc(population)", "asc(name)"]`  
 * **queryType**: Select how the query words are interpreted, it can be one of the following value:
  * **prefixAll**: all query words are interpreted as prefixes,
  * **prefixLast**: only the last word is interpreted as a prefix (default behavior),
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **highlightPreTag**: (string) Specify the string that is inserted before the highlighted parts in the query result (default to "&lt;em&gt;").
 * **highlightPostTag**: (string) Specify the string that is inserted after the highlighted parts in the query result (default to "&lt;/em&gt;").
 * **optionalWords**: (array of strings) Specify a list of words that should be considered as optional when found in the query.

You can easily retrieve settings or update them:

```sh
algoliasearch-cmd.sh getSettings contacts
```

```sh
echo '{"customRanking": ["desc(followers)"]}' > rankingSetting.json
algoliasearch-cmd.sh changeSettings contacts rankingSetting.json
```

List indexes
-------------
You can list all your indexes with their associated information (number of entries, disk size, etc.) with the `indexes` argument:

```sh
algoliasearch-cmd.sh indexes
```

Delete an index
-------------
You can delete an index using its name:

```sh
algoliasearch-cmd.sh deleteIndex contacts
```

Clear an index
-------------
You can delete the index content without removing settings and index specific API keys with the clearIndex command:

```sh
algoliasearch-cmd.sh clearIndex contacts
```

Batch writes
-------------

You may want to perform multiple operations with a single API call to reduce latency.
You can format the input in our [batch format](http://docs.algoliav1.apiary.io/#post-%2F1%2Findexes%2F%7BindexName%7D%2Fbatch) and use the command line tool with the `batch` argument to send the batch.

Example:
```sh
echo '{ "requests":[{"action": "addObject", "body": { "firstname": "Jimmie", "lastname": "Barninger"} }, {"action": "addObject", "body": { "firstname": "Warren", "lastname": "Speach"} } ] }' > batch.json
algoliasearch-cmd.sh batch contacts batch.json
```

Security / User API Keys
-------------

The admin API key provides full control of all your indexes. 
You can also generate user API keys to control security. 
These API keys can be restricted to a set of operations or/and restricted to a given index.

To list existing keys, you can use `listUserKeys` method:
```sh
# Lists global API Keys
algoliasearch-cmd.sh getACL
# Lists API Keys that can access only to this index
algoliasearch-cmd.sh getIndexACL
```

Each key is defined by a set of rights that specify the authorized actions. The different rights are:
 * **search**: allows to search,
 * **addObject**: allows to add/update an object in the index,
 * **deleteObject**: allows to delete an existing object,
 * **deleteIndex**: allows to delete index content,
 * **settings**: allows to get index settings,
 * **editSettings**: allows to change index settings.

Example of API Key creation:
```sh
# Creates a new global API key that can only perform search actions
echo '{"acl": ["search"]}' > acl.json
algoliasearch-cmd.sh addACL acl.json
# Creates a new API key that can only perform search action on this index
algoliasearch-cmd.sh addIndexACL acl.json
```
You can also create an API Key with advanced restrictions:
Add a validity period: the key will be valid only for a specific period of time (in seconds),
Specify the maximum number of API calls allowed from an IP address per hour. Each time an API call is performed with this key, a check is performed. If the IP at the origin of the call did more than this number of calls in the last hour, a 403 code is returned. Defaults to 0 (no rate limit). This parameter can be used to protect you from attempts at retrieving your entire content by massively querying the index.
Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited). This parameter can be used to protect you from attempts at retrieving your entire content by massively querying the index.

You can also create a temporary API key that will be valid only for a specific period of time (in seconds):
```sh
# Creates a new global API key that is valid for 300 seconds
echo '{"acl": ["search"], "validity": 300}' > acl.json
algoliasearch-cmd.sh addACL acl.json
# Creates a new index specific API key valid for 300 seconds, with a rate limit of 100 calls per hour per IP and a maximum of 20 hits
echo '{"acl": ["search"], "validity": 300, "maxQueriesPerIPPerHour": 100, "maxHitsPerQuery": 20}' > acl.json
algoliasearch-cmd.sh addIndexACL acl.json
```

Get the rights of a given key:
```sh
# Gets the rights of a global key
algoliasearch-cmd.sh getACL f420238212c54dcfad07ea0aa6d5c45f
# Gets the rights of an index specific key
algoliasearch-cmd.sh getIndexACL 71671c38001bf3ac857bc82052485107
```

Delete an existing key:
```sh
# Deletes a global key
algoliasearch-cmd.sh deleteACL f420238212c54dcfad07ea0aa6d5c45f
# Deletes an index specific key
algoliasearch-cmd.sh deleteIndexACL 71671c38001bf3ac857bc82052485107
```

Copy or rename an index
-------------

You can easily copy or rename an existing index using the `copy` and `move` commands.
**Note**: Move and copy commands overwrite destination index.

```sh
# Rename MyIndex in MyIndexNewName
algoliasearch-cmd.sh move MyIndex MyIndexNewName
# Copy MyIndex in MyIndexCopy
algoliasearch-cmd.sh copy MyIndex MyIndexCopy
```

The move command is particularly useful is you want to update a big index atomically from one version to another. For example, if you recreate your index `MyIndex` each night from a database by batch, you just have to:
 1. Import your database in a new index using [batches](#batch-writes). Let's call this new index `MyNewIndex`.
 1. Rename `MyNewIndex` in `MyIndex` using the move command. This will automatically override the old index and new queries will be served on the new one.

```sh
# Rename MyNewIndex in MyIndex (and overwrite it)
algoliasearch-cmd.sh move MyNewIndex MyIndex
```

Logs
-------------

You can retrieve the last logs via this API. Each log entry contains: 
 * Timestamp in ISO-8601 format
 * Client IP
 * Request Headers (API-Key is obfuscated)
 * Request URL
 * Request method
 * Request body
 * Answer HTTP code
 * Answer body
 * SHA1 ID of entry

You can retrieve the logs of your last 1000 API calls and browse them using the offset/length parameters:
 * ***offset***: Specify the first entry to retrieve (0-based, 0 is the most recent log entry). Default to 0.
 * ***length***: Specify the maximum number of entries to retrieve starting at offset. Defaults to 10. Maximum allowed value: 1000.

```sh
# Get last 10 log entries
algoliasearch-cmd.sh logs
# Get last 100 log entries
algoliasearch-cmd.sh logs "length=100"
```

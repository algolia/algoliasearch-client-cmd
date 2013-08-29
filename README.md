Algolia Search Command Line API Client
==================

This command line API Client is a small wrapper around CURL to easily expose our API.
The service is currently in Beta, you can request an invite on our [website](http://www.algolia.com/pricing/).

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
1. [Batch writes](#batch-writes)
1. [Security / User API Keys](#security--user-api-keys)

Setup
-------------
To setup the command line client, you have just to [download](https://github.com/algolia/algoliasearch-client-cmd/archive/master.zip) `algoliasearch-cmd.sh` and change `API_KEY`, `APPLICATION_ID` with the values you can find on [your Algolia account](http://www.algolia.com/users/edit).


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

 * **attributes**: a string that contains the names of attributes to retrieve separated by a comma.<br/>By default all attributes are retrieved.
 * **attributesToHighlight**: a string that contains the names of attributes to highlight separated by a comma.<br/>By default indexed attributes are highlighted. Numerical attributes cannot be highlighted. A **matchLevel** is returned for each highlighted attribute and can contain: "full" if all the query terms were found in the attribute, "partial" if only some of the query terms were found, or "none" if none of the query terms were found.
 * **attributesToSnippet**: a string that contains the names of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords'). Attributes are separated by a comma (Example: "attributesToSnippet=name:10,content:10").<br/>By default no snippet is computed.
 * **minWordSizeForApprox1**: the minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 3.
 * **minWordSizeForApprox2**: the minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 7.
 * **getRankingInfo**: if set to 1, the result hits will contain ranking information in _rankingInfo attribute.
 * **page**: *(pagination parameter)* page to retrieve (zero base).<br/>Defaults to 0.
 * **hitsPerPage**: *(pagination parameter)* number of hits per page.<br/>Defaults to 10.
 * **aroundLatLng**: search for entries around a given latitude/longitude (specified as two floats separated by a comma).<br/>For example `aroundLatLng=47.316669,5.016670`).<br/>You can specify the maximum distance in meters with the **aroundRadius** parameter (in meters) and the precision for ranking with **aroundPrecision** (for example if you set aroundPrecision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **insideBoundingBox**: search entries inside a given area defined by the two extreme points of a rectangle (defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).<br/>For example `insideBoundingBox=47.3165,4.9665,47.3424,5.0201`).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)
 * **queryType**: select how the query words are interpreted:
  * **prefixAll**: all query words are interpreted as prefixes (default behavior).
  * **prefixLast**: only the last word is interpreted as a prefix. This option is recommended if you have a lot of content to speedup the processing.
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **tags**: filter the query by a set of tags. You can AND tags by separating them by commas. To OR tags, you must add parentheses. For example, `tags=tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*.<br/>At indexing, tags should be added in the _tags attribute of objects (for example `{"_tags":["tag1","tag2"]}` )

```sh
algoliasearch-cmd.sh query contacts "query string" "attributes=firstname,lastname&hitsPerPage=50"
```

The server response will look like:

```javascript
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "company": "California Paint & Wlpaper Str",
      "address": "Box #-4038",
      "city": "Modesto",
      "county": "Stanislaus",
      "state": "CA",
      "zip": "95352",
      "phone": "209-525-7568",
      "fax": "209-525-4389",
      "email": "jimmie@barninger.com",
      "web": "http://www.jimmiebarninger.com",
      "followers": 3947,
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
        },
        "address": {
          "value": "Box #-4038",
          "matchLevel": "none"
        },
        "city": {
          "value": "Modesto",
          "matchLevel": "none"
        },
        "email": {
          "value": "<em>jimmie</em>@barninger.com",
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
  "params": "query=jimmie+paint&"
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

 * **minWordSizeForApprox1**: (integer) the minimum number of characters to accept one typo (default = 3).
 * **minWordSizeForApprox2**: (integer) the minimum number of characters to accept two typos (default = 7).
 * **hitsPerPage**: (integer) the number of hits per page (default = 10).
 * **attributesToRetrieve**: (array of strings) default list of attributes to retrieve in objects.
 * **attributesToHighlight**: (array of strings) default list of attributes to highlight.
 * **attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords')<br/>By default no snippet is computed.
 * **attributesToIndex**: (array of strings) the list of fields you want to index.<br/>By default all textual attributes of your objects are indexed, but you should update it to get optimal results.<br/>This parameter has two important uses:
  * *Limit the attributes to index*.<br/>For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
  * *Control part of the ranking*.<br/>Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list.
 * **ranking**: (array of strings) controls the way results are sorted.<br/>We have four available criteria: 
  * **typo**: sort according to number of typos,
  * **geo**: sort according to decreassing distance when performing a geo-location based search,
  * **position**: sort according to the proximity of query words in the object,
  * **exact**: sort according to the number of words that are matched identical to query word (and not as a prefix),
  * **custom**: sort according to a user defined formula set in **customRanking** attribute.<br/>The standard order is ["typo", "geo", position", "exact", "custom"]
 * **queryType**: select how the query words are interpreted:
  * **prefixAll**: all query words are interpreted as prefixes (default behavior).
  * **prefixLast**: only the last word is interpreted as a prefix. This option is recommended if you have a lot of content to speedup the processing.
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **customRanking**: (array of strings) lets you specify part of the ranking.<br/>The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
For example `"customRanking" => ["desc(population)", "asc(name)"]`

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
algoliasearch-cmd.sh deletIndex contacts
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
You can also create a temporary API key that will be valid only for a specific period of time (in seconds):
```sh
# Creates a new global API key that is valid for 300 seconds
echo '{"acl": ["search"], "validity": 300}' > acl.json
algoliasearch-cmd.sh addACL acl.json
# Creates a new index specific API key valid for 300 seconds
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

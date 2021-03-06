# Mappable

* Turbocharge swift 4 JSON codable protocol with extra functionality. (easy development, easy debugging..)

* By conforming the protocol, any struct or class property values is easily accessible, essential under development and debugging process.

* It's very lightweight and fat free.

* It's easily extendable with your own methodes through protocol extension.

### Granular logging class that can easy print log with different level.

* Can print log in different leves (warning, error, debug, info, verbose...)

* Can enable and disable globally and individually per class.

* Class log config can overriden global config settings.

* Fallback to globally log config if per class log config is undefined.

* Global logging methode that handle "http/api" and "encoder/decode" logs.

### Installation and documentation generation

Run **"pod install"** first time when downloaded from repo. Project won't compile without pod properly set up. 


Run **docs.sh** to generate documentation if you have [**Jazzy**](https://github.com/realm/jazzy) installed.

## What you need to implement (It's easy.)

`Mappable` object's property value.

**Note:** If you don't have any property to include and/or exclude, just ``return propertyValuesRaw``.

```swift
var propertyValues: [String: Any] {get}
```

```swift

    public var propertyValues: [String:Any] {
    
	// Raw property to exclude
        let excludeJsonProperty = ["productID", "itemNumber"]
		
	// Computed property want to includes
        var addtionalPropertyInfo = [String: Any]()
        addtionalPropertyInfo["computedPropertyA"] = self.computedPropertyA
        addtionalPropertyInfo["computedPropertyB"] = self.computedPropertyB
        addtionalPropertyInfo["computedPropertyC"] = self.computedPropertyC

	// Adjust representation of propertyValues
        return adjustPropertyValues(excluded: excludeJsonProperty, additional: addtionalPropertyInfo)
    }

```

## What you get for free from Mappable protocol:

Description of `Mappable` object, contain object name and object type info.

```swift
var objectInfo: String { get }
```
### Raw information of property without computed property
`Mappable` object property names that is not included computed property.

```swift
var propertyNamesRaw: [String] { get }

```

`Mappable` property name value pair that is not included computed property.

```swift
var propertyValuesRaw: [String : Any] { get }
```

`Mappable` property name value pair with `Optional` value unwrapped, doesn't included computed property.

```swift
var propertyUnwrappedDataRaw: [String : Any] { get }
```

`Mappable` property value without computed property in description,
can either print out to console for debugging, logs to file or sendt out to log collection system.

```swift    
var objectDescriptionRaw: String { get }
```

### Information of property with computed property

`Mappable` property names which is included computed property.

```swift 
var propertyNames: [String] { get }
```

`Mappable` property name value pair with `Optional` value unwrapped, is included computed property.

```swift 
var propertyUnwrappedData: [String : Any] { get }
```

`Mappable` property value with computed property as part of the description, can either print out to console for debugging, logs to file or sendt out to log collection system.
 
```swift
var objectDescription: String { get }
```

### Subscript

Subscript to access `Mappable` object's property value.

```swift 
subscript(key: String) -> Any? { get }
```

### Methode to include computed property values to raw property value

Adjust property values presentation for 'Mappable' object.

**Note:** For example, we want to hide some private, fileprivate, or raw properties values from json, and added some computed property values to the representation.
In this way, we can shape what data we want consumer to see with `propertyValues`.

```swift 
func adjustPropertyValues(excluded property: [String] = [""], additional propertyInfo: [String:Any] = [String: Any]()) -> [String:Any]

```

### JSON representation
Show raw `Mappable` object in json representation.

```swift 
func propertyJSONRepresentation(dateFormatter: DateFormatter) -> String

```

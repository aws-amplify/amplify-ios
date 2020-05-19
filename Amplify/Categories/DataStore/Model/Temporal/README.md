## Custom Data Types

`DataStore > Model > Temporal`

Model-based programming aims to simplify data management on apps and enable developers to focus on the business and UI implementation while the technical aspects on persisting data are abstracted away from the core logic. Therefore, data types are a critical piece of it.

This module provides types that will complement the Swift provided ones when more control is needed over the persisted values.

**Table of Contents**

1. [Temporal](#temporal)
   1. [Date, DateTime, Time](#date-datetime-time)
   2. [ISO-8601](#iso-8601)
   3. [The underlying `Date`](#the-underlying-date)
   4. [Operations](#operations)
   5. [References](#references)

### 1. Temporal

The Swift foundation module provides the [Date](https://developer.apple.com/documentation/foundation/date) struct that represents a single point in time and can fit any precision, calendrical system or time zone. While that approach is concise and powerful, when it comes to representing persistent data its flexibility can result in ambiguity (i.e. should only the date portion be used or both date and time).


#### 1.1. `Date`, `DateTime`, `Time`

The `TemporalSpec` protocol was introduced to establish a more strict way to represent dates that make sense in a data persistence context.

#### 1.2. ISO-8601

The temporal implementations rely on a fixed [ISO-8601](https://www.iso.org/iso-8601-date-and-time-format.html) Calendar implementation ([`.iso8601`](https://developer.apple.com/documentation/foundation/calendar/identifier/iso8601)). If a representation of the date is needed in different calendars, use the underlying date object described in the next section.

#### 1.3. The underlying `Date`

Both `DateTime` and `Time` are backed by a [`Date`](https://developer.apple.com/documentation/foundation/date) instance. Therefore, they are compatible with all existing Date APIs from Foundation, including third-party libraries.

#### 1.4. Operations

Date operations are often needed when implementing business logic. Although Swift offers great support for complex date operations using [`Calendar`](https://developer.apple.com/documentation/foundation/calendar), simple use-cases often require several lines of code. The `TemporalSpec` implementation offers utilities that enable simple date operations to be defined in a readable and idiomatic way.

Time:

```swift
// current time plus 2 hours
let time = Time.now + .hours(2)
```

Date/Time:

```swift
// current date/time 2 weeks ago
let datetime = DateTime.now - .weeks(2)
```

#### 1.5. References

Some resources that inspired types defined here:

- Joda Time: https://www.joda.org/joda-time/
- Ruby on Rails Date API: https://api.rubyonrails.org/classes/Date.html

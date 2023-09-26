# YYTagLayout
A Custom layout for show tags

> Usage
- Just like `VStack` or `HStack` you can customize the `h & v spacing` 
  ```
        YYTagLayout(alignment: .leading,horizontalSpacing: 10,verticalSpacing: 10) {
            ForEach(tags,id: \.self) { tag in
                TagItem(tag: tag)
            }
        }
        .padding(10)
  ```

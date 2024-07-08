# Markdown Cheat Sheet

Thanks for visiting [The Markdown Guide](https://www.markdownguide.org)!

This Markdown cheat sheet provides a quick overview of all the Markdown syntax elements. It can’t cover every edge case, so if you need more information about any of these elements, refer to the reference guides for [basic syntax](https://www.markdownguide.org/basic-syntax) and [extended syntax](https://www.markdownguide.org/extended-syntax).

## Basic Syntax

These are the elements outlined in John Gruber’s original design document. All Markdown applications support these elements.

### Heading

# H1
## H2
### H3

### Bold

**bold text**

### Italic

*italicized text*

### Blockquote

> blockquote

### Ordered List

1. First item
2. Second item
3. Third item

### Unordered List

- First item
- Second item
- Third item

### Code

`code`

### Horizontal Rule

---

### External Link

[Markdown Guide](https://www.markdownguide.org)

### Internal Link

For internal links (links to other NaviPartner documentation pages, i.e. related links) follow these steps:

1. Use the "relative path" to the page omitting the protocol and domain name (right-click on the page you wish to link to and select the **Copy Relative Path** option).   
   For example use "/public/retail/eft/howto/mobilepay" instead of https://docs.navipartner.com/retail/eft/howto/mobilepay.html.
2. For the link address use the path of the page in the site regardless of the location of the file in the repository.       
   Do not use the .md suffix.
3. Don't forget to start the path with a forward slash: /.

Putting this all together an internal link looks like this:

[An Internal Link](/public/retail/eft/howto/mobilepay)

### Image

![alt text](https://www.markdownguide.org/assets/images/tux.png)

### Resizing images

<img src="https://www.markdownguide.org/assets/images/tux.png" width="200">

### Videos

[Microsoft documentation instructions](https://docs.microsoft.com/en-us/dynamics365/business-central/purchasing-how-record-purchases)

## Extended Syntax

These elements extend the basic syntax by adding additional features. Not all Markdown applications support these elements.

### Table

| Syntax | Description |
| ----------- | ----------- |
| Header | Title |
| Paragraph | Text |

If you're feeling lazy, you can generate a table on [this website](https://www.tablesgenerator.com/markdown_tables).

### Fenced Code Block

```
{
  "firstName": "John",
  "lastName": "Smith",
  "age": 25
}
```

### Footnote

Here's a sentence with a footnote. [^1]

[^1]: This is the footnote.

### Heading ID

### My Great Heading {#custom-id}

### Definition List

term
: definition

### Strikethrough

~~The world is flat.~~

### Task List

- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media

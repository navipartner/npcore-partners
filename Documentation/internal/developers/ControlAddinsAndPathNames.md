# Control Add-ins and path names

While most of AL stuff is quite oblivious of the physical location of the source file, `controladdin` objects are quite different.

[[_TOC_]]

##;TLDR
> Don't just change the path of a folder containing control add-ins, and then simply fix the paths declared in `controladdin` files. That will make the AL compiler happy, but will break any calls to `Microsoft.Dynamics.NAV.GetImageResource` method in JavaScript.
> Never use any special characters in paths referenced in `controladdin` objects.

## Where is the problem?


Consider this:

```
controladdin Foo {
  Scripts = 'src/Foo/main.js';
  Images = 'src/Foo/main.png';
}
```

Then imagine your script does this

```javascript
// main.js

const img = document.createElement("img");
img.src = Microsoft.Dynamics.NAV.GetImageResource("src/Foo/main.png");
document.body.appendChild(img);
```

It works fine, you get a nice image shown in the control add-in.

Then you realize that `src/Foo` is a bad path for the control add-in, and then you change the path to `src/Controls/Foo`. Obviously, this makes compiler go crazy because it can't find the referenced script and image files in the `src/Foo` folder anymore.

So you change the control add-in object:

```al
controladdin Foo {
  Scripts = 'src/Controls/Foo/main.js';
  Images = 'src/Controls/Foo/main.png';
}
```

It compiles nice, and you are happy and you commit it.

Do you see the problem? Do you see why it will fail at runtime?

Yes, because of this line:

```javascript
img.src = Microsoft.Dynamics.NAV.GetImageResource("src/Foo/main.png");
```

Changing path names of control add-ins is not an AL-only problem. Any time you reference any images that you retrieve using the [`Microsoft.Dynamics.NAV.GetImageResource` method](https://docs.microsoft.com/en-us/dynamics-nav/getimageresource-method) you must use the full relative path to the project root. This is - however - not checked by the AL compiler (obviously, it's JavaScript code that's affected).

This kind of issues are difficult to spot, but you can apply this rule: if you change path of a `controladdin` object, and the object references any `Images`, then you must look through JavaScript code and correct any references that reference the project path.

## How to fix it?

A good suggestion would be to simply do this:

```al
controladdin Foo {
  Scripts = 
    'src/Foo/resourceMap.js'
    'src/Foo/main.js';
  Images = 
    'src/Foo/img1.png',
    'src/Foo/img2.png',
    'src/Foo/img3.png';
}
```

```javascript
// resourceMap

const CONTROL_RESOURCE_PATH = 'src/Foo';
window.mapControlResourcePath = img => `${CONTROL_RESOURCE_PATH}/${img}`;
```

```javascript
// main.js

const src1 = mapControlResourcePath("img1");
const src2 = mapControlResourcePath("img2");
const src3 = mapControlResourcePath("img3");
```

Then, if you change `src/Foo` to `src/Controls/Foo` you simply change the `resourceMap.js` script like this:

```javascript
const CONTROL_RESOURCE_PATH = 'src/Controls/Foo';
```

Then, of course, you can have image subfolders, like this:

```
// controladadin Foo
  Images = 
    'src/Foo/images/users/user1.png',
    'src/Foo/images/badges/happy.png',
    'src/Foo/images/badges/sad.png';
```

... and read them all like this:

```javascript
const src1 = mapControlResourcePath("images/users/user1.png");
const src2 = mapControlResourcePath("images/badges/happy.png");
const src3 = mapControlResourcePath("images/badges/sad.png");
```

## Spaces (or special characters) in path names

One other very important rule about path names is that path names of any items (scripts, stylesheets, images) references in `controladdin` objects must not contain spaces or any special characters.

Did you ever notice that if you enter something like this into the browser address bar?

```
https://www.google.com/search?q=what's new?
```

... your browser will change it into:
```
https://www.google.com/search?q=what%27s%20new?
```

That's because characters `" "` and `"'"` are "special" characters when it comes to URLs. URLs used so called [Percent-encoding](https://en.wikipedia.org/wiki/Percent-encoding) to represent any characters that fall outside letters, numbers, and `"-"`, `"."`, `"_"`, `"~"`. If you want to get really geeky about this stuff, check out [RFC 1738](https://tools.ietf.org/html/rfc1738).

Now, imagine you want to have this control add-in:

```
controladdin "Foo Bar" {
  Scripts = 'src/Control Add-ins/Foo Bar/main.js';
  Images = 'src/Control Add-ins/Foo Bar/main.png';
}
```

Again, the AL compiler couldn't care less. As long as the files are where `controladdin` says they are, it will happily compile them.

However, if you attempt to run this control add-in, you are in for a surprise:

![image.png](/.attachments/image-9ae1e655-57a5-4f81-99b9-a61416b243ea.png)

Well, when showing your control add-in, the BC front-end runtime (ASP.NET) will first unpack all the control add-in resources and deploy it into a folder on the IIS. Then, it will check whether all files referenced in the control add-in actually physically exist. To do that, it uses the paths declared in your control add-in.

Apparently - it doesn't do the proper URL encoding first. Whether it's a bug (you could definitely argue that it is) or it's intentional (I don't know why it would be, but hey - their castle, their rules).

Simply fix it like this:

```
controladdin "Foo Bar" {
  Scripts = 'src/ControlAdd-Ins/FooBar/main.js';
  Images = 'src/Control Add-Ins/FooBar/main.png';
}
```

... and you're good to go.

enum 6059922 "NPR CloudflareMediaVariants"
{
    Extensible = false;

    value(0; ORIGINAL)
    {
        Caption = 'Original';
    }

    // square 70x70 px
    value(1; SMALL)
    {
        Caption = 'Small';
    }

    // square 240x240 px
    value(2; MEDIUM)
    {
        Caption = 'Medium';
    }

    // square 360x360 px
    value(3; LARGE)
    {
        Caption = 'Large';
    }

    // maintain aspect ratio, max width or height 360 px
    value(4; THUMBNAIL)
    {
        Caption = 'Thumbnail';
    }

    // maintain aspect ratio, max width or height 1024 px
    value(5; PREVIEW)
    {
        Caption = 'Preview';
    }

}
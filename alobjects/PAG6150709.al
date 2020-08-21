page 6150709 ".NET Dependency Map"
{
    Caption = '.NET Dependency Map';
    PageType = List;
    SourceTable = ".NET Dependency Map";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Type Name"; "Type Name")
                {
                    ApplicationArea = All;
                }
                field("Instantiate From Assembly Name"; "Instantiate From Assembly Name")
                {
                    ApplicationArea = All;
                }
                field("Instantiate From Type Name"; "Instantiate From Type Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}


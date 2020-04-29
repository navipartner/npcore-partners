page 6059975 "Variety Fields Setup"
{
    // VRT1.11/JDH /20160602 CASE 242940 Added Image to action
    // NPR5.28/JDH /20161128 CASE 255961 Added OnDrillDown Codeunit Id
    // NPR5.32/JDH /20170510 CASE 274170 Field Type Name Added
    // NPR5.47/NPKNAV/20181026  CASE 327541-01 Transport NPR5.47 - 26 October 2018

    Caption = 'Variety Fields Setup';
    PageType = List;
    SourceTable = "Variety Field Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Table No.";"Table No.")
                {
                }
                field("Field No.";"Field No.")
                {
                }
                field(Disabled;Disabled)
                {
                }
                field("Variety Matrix Subscriber 1";"Variety Matrix Subscriber 1")
                {
                }
                field("Sort Order";"Sort Order")
                {
                }
                field(Description;Description)
                {
                }
                field("Validate Field";"Validate Field")
                {
                }
                field("Editable Field";"Editable Field")
                {
                }
                field("Is Table Default";"Is Table Default")
                {
                }
                field("OnDrillDown Codeunit ID";"OnDrillDown Codeunit ID")
                {
                    Visible = false;
                }
                field("Use Location Filter";"Use Location Filter")
                {
                    Visible = false;
                }
                field("Use Global Dim 1 Filter";"Use Global Dim 1 Filter")
                {
                    Visible = false;
                }
                field("Use Global Dim 2 Filter";"Use Global Dim 2 Filter")
                {
                    Visible = false;
                }
                field("Secondary Type";"Secondary Type")
                {
                }
                field("Secondary Table No.";"Secondary Table No.")
                {
                }
                field("Secondary Field No.";"Secondary Field No.")
                {
                }
                field("Variety Matrix Subscriber 2";"Variety Matrix Subscriber 2")
                {
                }
                field("Secondary Description";"Secondary Description")
                {
                }
                field("Use Location Filter (Sec)";"Use Location Filter (Sec)")
                {
                    Visible = false;
                }
                field("Use Global Dim 1 Filter (Sec)";"Use Global Dim 1 Filter (Sec)")
                {
                    Visible = false;
                }
                field("Use Global Dim 2 Filter (Sec)";"Use Global Dim 2 Filter (Sec)")
                {
                    Visible = false;
                }
                field("OnLookup Subscriber";"OnLookup Subscriber")
                {
                }
                field("Use OnLookup Return Value";"Use OnLookup Return Value")
                {
                }
                field("OnDrillDown Subscriber";"OnDrillDown Subscriber")
                {
                }
                field("Use OnDrillDown Return Value";"Use OnDrillDown Return Value")
                {
                }
                field("Lookup Type";"Lookup Type")
                {
                    Visible = false;
                }
                field("Lookup Object No.";"Lookup Object No.")
                {
                    Visible = false;
                }
                field("Call Codeunit with rec";"Call Codeunit with rec")
                {
                    Visible = false;
                }
                field("Function Identifier";"Function Identifier")
                {
                    Visible = false;
                }
                field("Field Type Name";"Field Type Name")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Insert Default Setup")
            {
                Caption = 'Insert Default Setup';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    InitVarietyFields;
                end;
            }
        }
    }
}


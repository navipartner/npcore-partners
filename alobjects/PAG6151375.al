page 6151375 "CS UI"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.44/CLVA/20180719 CASE 315503 Added field "Set defaults from last record"
    // NPR5.48/CLVA/20181113 CASE 335606 Added field "Warehouse Type"
    // NPR5.49/CLVA/20190327 CASE 349554 Added field "Expand Summary Items"
    // NPR5.50/CLVA/20190327 CASE 247747 Added field "Hid Fulfilled Lines"
    // NPR5.50/CLVA/20190327 CASE 347971 Added field "Add Posting Options"

    Caption = 'CS UI';
    DataCaptionFields = "Code";
    PageType = ListPlus;
    SourceTable = "CS UI Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Form Type";"Form Type")
                {
                }
                field("Expand Summary Items";"Expand Summary Items")
                {
                }
                field("Hid Fulfilled Lines";"Hid Fulfilled Lines")
                {
                }
                field("Set defaults from last record";"Set defaults from last record")
                {
                }
                field("Add Posting Options";"Add Posting Options")
                {
                }
                field("No. of Records in List";"No. of Records in List")
                {
                }
                field("Handling Codeunit";"Handling Codeunit")
                {
                    LookupPageID = Objects;
                }
                field("Next UI";"Next UI")
                {
                }
                field("Start UI";"Start UI")
                {
                }
                field("Warehouse Type";"Warehouse Type")
                {
                }
            }
            part(Control9;"CS UI Subform")
            {
                SubPageLink = "UI Code"=FIELD(Code);
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Mini Form")
            {
                Caption = '&Mini Form';
                Image = MiniForm;
                action("&Functions")
                {
                    Caption = '&Functions';
                    Image = "Action";
                    RunObject = Page "CS UI Functions";
                    RunPageLink = "UI Code"=FIELD(Code);
                }
                action("Reset Field Defaults")
                {
                    Caption = 'Reset Field Defaults';
                    Image = ClearFilter;

                    trigger OnAction()
                    var
                        CSHelperFunctions: Codeunit "CS Helper Functions";
                    begin
                        CSHelperFunctions.ResetFieldDefaults(Rec);
                    end;
                }
            }
        }
    }
}


page 6151375 "NPR CS UI"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.44/CLVA/20180719 CASE 315503 Added field "Set defaults from last record"
    // NPR5.48/CLVA/20181113 CASE 335606 Added field "Warehouse Type"
    // NPR5.49/CLVA/20190327 CASE 349554 Added field "Expand Summary Items"
    // NPR5.50/CLVA/20190327 CASE 247747 Added field "Hid Fulfilled Lines"
    // NPR5.50/CLVA/20190327 CASE 347971 Added field "Add Posting Options"
    // NPR5.51/CLVA/20190612 CASE 357577 Added field "Update Posting Date"
    // NPR5.52/CLVA/20191010 CASE 370452 Added field "Posting Type"
    //                                   Removed field "Add Posting Options"

    Caption = 'CS UI';
    DataCaptionFields = "Code";
    PageType = ListPlus;
    UsageCategory = Administration;
    SourceTable = "NPR CS UI Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Form Type"; "Form Type")
                {
                    ApplicationArea = All;
                }
                field("Expand Summary Items"; "Expand Summary Items")
                {
                    ApplicationArea = All;
                }
                field("Hid Fulfilled Lines"; "Hid Fulfilled Lines")
                {
                    ApplicationArea = All;
                }
                field("Set defaults from last record"; "Set defaults from last record")
                {
                    ApplicationArea = All;
                }
                field("Posting Type"; "Posting Type")
                {
                    ApplicationArea = All;
                }
                field("Update Posting Date"; "Update Posting Date")
                {
                    ApplicationArea = All;
                }
                field("No. of Records in List"; "No. of Records in List")
                {
                    ApplicationArea = All;
                }
                field("Handling Codeunit"; "Handling Codeunit")
                {
                    ApplicationArea = All;
                    LookupPageID = Objects;
                }
                field("Next UI"; "Next UI")
                {
                    ApplicationArea = All;
                }
                field("Start UI"; "Start UI")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Type"; "Warehouse Type")
                {
                    ApplicationArea = All;
                }
            }
            part(Control9; "NPR CS UI Subform")
            {
                SubPageLink = "UI Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = All;
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
                    RunObject = Page "NPR CS UI Functions";
                    RunPageLink = "UI Code" = FIELD(Code);
                    ApplicationArea = All;
                }
                action("Reset Field Defaults")
                {
                    Caption = 'Reset Field Defaults';
                    Image = ClearFilter;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
                    begin
                        CSHelperFunctions.ResetFieldDefaults(Rec);
                    end;
                }
            }
        }
    }
}


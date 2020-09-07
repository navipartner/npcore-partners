page 6059985 "NPR Retail Document Activities"
{
    // NPR4.14/RMT/20150826 CASE 216519 Added column "Number of Open Orders" and "Number of Posted Orders"
    //                                    toggle showing the queues based on the "Retail Setup"
    // NPR4.18/BHR/201151611 CASE 227343 Set Correct Caption

    Caption = 'Retail Document Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Document Cue";

    layout
    {
        area(content)
        {
            cuegroup("Open Documents")
            {
                Caption = 'Open Documents';
                field("Selection Contracts Open"; "Selection Contracts Open")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Document List";
                }
                field("Customizations Open"; "Customizations Open")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Document List";
                }
                field("Retail Orders Open"; "Retail Orders Open")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Document List";
                    Visible = NOT UseStandardOrderDocument;
                }
                field("Number of Open Orders"; "Number of Open Orders")
                {
                    ApplicationArea = All;
                    Visible = UseStandardOrderDocument;
                }

                actions
                {
                    action("New Selection Contract")
                    {
                        Caption = 'New Selection Contract';
                        RunObject = Page "NPR Retail Document Header";
                        RunPageMode = Create;
                        RunPageView = SORTING("Document Type", "No.")
                                      WHERE("Document Type" = CONST("Selection Contract"));
                        ApplicationArea=All;
                    }
                    action("New Customization")
                    {
                        Caption = 'New Customization';
                        RunObject = Page "NPR Retail Document Header";
                        RunPageMode = Create;
                        RunPageView = SORTING("Document Type", "No.")
                                      WHERE("Document Type" = CONST("Selection Contract"));
                        ApplicationArea=All;
                    }
                    action("New Retail Order")
                    {
                        Caption = 'New Retail Order';
                        RunObject = Page "NPR Retail Document Header";
                        RunPageMode = Create;
                        RunPageView = SORTING("Document Type", "No.")
                                      WHERE("Document Type" = CONST("Selection Contract"));
                        ApplicationArea=All;
                    }
                }
            }
            cuegroup("Cashed Documents")
            {
                Caption = 'Cashed Documents';
                field("Selection Contracts Cashed"; "Selection Contracts Cashed")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Document List";
                }
                field("Customizations Cashed"; "Customizations Cashed")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Document List";
                }
                field("Retail Orders Cashed"; "Retail Orders Cashed")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Document List";
                    Visible = NOT UseStandardOrderDocument;
                }
                field("Number of Posted Orders"; "Number of Posted Orders")
                {
                    ApplicationArea = All;
                    Visible = UseStandardOrderDocument;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        //-NPR4.14
        RetailSetup.Get;
        UseStandardOrderDocument := RetailSetup."Use Standard Order Document";
        //+NPR4.14
    end;

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;

    var
        UseStandardOrderDocument: Boolean;
}


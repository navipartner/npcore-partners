page 6151582 "NPR Event Events by Attributes"
{
    Caption = 'Events by Attributes';
    CardPageID = "NPR Event Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SaveValues = true;
    SourceTable = Job;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(Control6014408)
            {
                ShowCaption = false;
                field(FilterDescription; FilterDescription)
                {

                    Caption = 'Attributes Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Attributes Filter field';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {

                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Status"; Rec."NPR Event Status")
                {

                    ToolTip = 'Specifies the value of the NPR Event Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."NPR Total Amount")
                {

                    ToolTip = 'Specifies the value of the NPR Total Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(View)
            {
                Caption = 'View';
                Image = View;
                RunObject = Page "NPR Event Card";
                RunPageLink = "No." = FIELD("No.");
                RunPageMode = View;

                ToolTip = 'Executes the View action';
                ApplicationArea = NPRRetail;
            }
            action(SelectAttributeFilter)
            {
                Caption = 'Select Attribute Filter';
                Image = "Filter";

                ToolTip = 'Executes the Select Attribute Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EventAttributeTempFilters: Page "NPR Event Attr. Temp. Filters";
                    EventAttributeTempFilter: Record "NPR Event Attr. Temp. Filter";
                    EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
                    Job: Record Job;
                begin
                    EventAttributeTempFilters.LookupMode := true;
                    if EventAttributeTempFilters.RunModal() = ACTION::LookupOK then begin
                        Rec.Reset();
                        EventAttributeTempFilters.GetRecord(EventAttributeTempFilter);
                        FilterDescription := EventAttributeTempFilter.Description;
                        if not EventAttrMgt.FindEventsInAttributesFilter(EventAttributeTempFilter."Template Name", EventAttributeTempFilter."Filter Name", Job) then
                            SetDefaultFilter()
                        else begin
                            Rec.Copy(Job);
                            Rec.MarkedOnly(true);
                        end;
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ClearFilter)
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;

                ToolTip = 'Executes the Clear Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    SetDefaultFilter();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetDefaultFilter();
    end;

    var
        FilterDescription: Text;

    local procedure SetDefaultFilter()
    begin
        Rec.SetRange("No.", '%$');
    end;
}


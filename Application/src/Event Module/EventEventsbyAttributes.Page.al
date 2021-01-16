page 6151582 "NPR Event Events by Attributes"
{
    // NPR5.33/TJ  /20170628 CASE 277946 New object created
    // NPR5.38/TJ  /20171023 CASE 291965 Added View action

    Caption = 'Events by Attributes';
    CardPageID = "NPR Event Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SaveValues = true;
    SourceTable = Job;

    layout
    {
        area(content)
        {
            group(Control6014408)
            {
                ShowCaption = false;
                field(FilterDescription; FilterDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Attributes Filter';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Attributes Filter field';
                }
            }
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                }
                field("Event Status"; "NPR Event Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Event Status field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Total Amount"; "NPR Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Total Amount field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the View action';
            }
            action(SelectAttributeFilter)
            {
                Caption = 'Select Attribute Filter';
                Image = "Filter";
                ApplicationArea = All;
                ToolTip = 'Executes the Select Attribute Filter action';

                trigger OnAction()
                var
                    EventAttributeTempFilters: Page "NPR Event Attr. Temp. Filters";
                    EventAttributeTempFilter: Record "NPR Event Attr. Temp. Filter";
                    EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
                    Job: Record Job;
                begin
                    EventAttributeTempFilters.LookupMode := true;
                    if EventAttributeTempFilters.RunModal = ACTION::LookupOK then begin
                        Reset;
                        EventAttributeTempFilters.GetRecord(EventAttributeTempFilter);
                        FilterDescription := EventAttributeTempFilter.Description;
                        if not EventAttrMgt.FindEventsInAttributesFilter(EventAttributeTempFilter."Template Name", EventAttributeTempFilter."Filter Name", Job) then
                            SetDefaultFilter()
                        else begin
                            Copy(Job);
                            MarkedOnly(true);
                        end;
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ClearFilter)
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;
                ApplicationArea = All;
                ToolTip = 'Executes the Clear Filter action';

                trigger OnAction()
                begin
                    SetDefaultFilter();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetDefaultFilter;
    end;

    var
        FilterDescription: Text;

    local procedure SetDefaultFilter()
    begin
        SetRange("No.", '%$');
    end;
}


page 6151582 "NPR Event Events by Attributes"
{
    Extensible = False;
    Caption = 'Events by Attributes';
    CardPageID = "NPR Event Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
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

                    Caption = 'Attributes Filter';
                    Editable = false;
                    ToolTip = 'Specifies the filter set on attributes.';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the number of the event.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {

                    ToolTip = 'Specifies the Bill-to Customer No. of the event';
                    ApplicationArea = NPRRetail;
                }
                field("Event Status"; Rec."NPR Event Status")
                {

                    ToolTip = 'Specifies the status of the event.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the starting date of the event''s validity.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."NPR Total Amount")
                {

                    ToolTip = 'Specifies the total amount to be charged for the event.';
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

                ToolTip = 'View filters which are set on specific attributes.';
                ApplicationArea = NPRRetail;
            }
            action(SelectAttributeFilter)
            {
                Caption = 'Select Attribute Filter';
                Image = "Filter";

                ToolTip = 'Select which filters to set on specific attributes';
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

                ToolTip = 'Clear all filters.';
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


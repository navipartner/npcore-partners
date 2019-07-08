page 6060016 "GIM - Import Buffer"
{
    Caption = 'GIM - Import Buffer';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Import Buffer";

    layout
    {
        area(content)
        {
            group(Control6150614)
            {
                ShowCaption = false;
                field(ShowErrors;ShowErrors)
                {
                    Caption = 'Show Errors Only';

                    trigger OnValidate()
                    begin
                        if not ShowErrors then begin
                          Reset;
                          SetView(AllFilters);
                          CurrPage.Update(false);
                        end else begin
                          if FindSet then
                            repeat
                              Mark(ApplyWarnFormat());
                            until Next = 0;
                          MarkedOnly(true);
                          CurrPage.Update(false);
                        end;
                    end;
                }
            }
            repeater(Group)
            {
                field("Row No.";"Row No.")
                {
                    Editable = false;
                }
                field("Column No.";"Column No.")
                {
                    Editable = false;
                }
                field("Column Name";"Column Name")
                {
                    Editable = false;
                }
                field("Parsed Text";"Parsed Text")
                {
                    Style = Unfavorable;
                    StyleExpr = UseStyle;

                    trigger OnValidate()
                    begin
                        UseStyle := ApplyWarnFormat();
                    end;
                }
                field("Skip Processing";"Skip Processing")
                {
                }
            }
            part(ColumnIDLink;"GIM - Import Buffer Subpage")
            {
                Caption = 'Mapping Errors';
                Editable = false;
                SubPageLink = "Document No."=FIELD("Document No."),
                              "Row No."=FIELD("Row No."),
                              "Column ID"=FIELD("Column No."),
                              "Fail Reason"=FILTER(<>'');
            }
            part(FilterValueLink;"GIM - Import Buffer Subpage")
            {
                Caption = 'Filtering Errors';
                Editable = false;
                SubPageLink = "Document No."=FIELD("Document No."),
                              "Row No."=FIELD("Row No."),
                              "Filter Value"=FIELD("Column No."),
                              "Fail Reason"=FILTER(<>'');
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Entities)
            {
                Caption = 'Entities';
                Image = ImportChartOfAccounts;
                RunObject = Page "GIM - Import Entities";
                RunPageLink = "Document No."=FIELD("Document No."),
                              "Row No."=FIELD("Row No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UseStyle := ApplyWarnFormat();
    end;

    trigger OnOpenPage()
    begin
        AllFilters := GetView;
    end;

    var
        [InDataSet]
        UseStyle: Boolean;
        ImportBufferDetail: Record "GIM - Import Buffer Detail";
        ShowErrors: Boolean;
        DocNo: Code[20];
        AllFilters: Text;

    local procedure ApplyWarnFormat(): Boolean
    begin
        ImportBufferDetail.SetRange("Document No.","Document No.");
        ImportBufferDetail.SetRange("Row No.","Row No.");
        if ImportBufferDetail.FindSet then
          repeat
            if ((ImportBufferDetail."Column ID" = "Column No.") or (ImportBufferDetail."Filter Value" = Format("Column No.")))
               and
               (ImportBufferDetail."Failed Data Type Validation" or
               ImportBufferDetail."Failed Data Mapping" or
               ImportBufferDetail."Failed Data Verification" or
               ImportBufferDetail."Failed Data Creation") then
              exit(true);
          until ImportBufferDetail.Next = 0;
        exit(false);
    end;
}


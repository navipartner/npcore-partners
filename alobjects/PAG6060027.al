page 6060027 "GIM - Mapping 2"
{
    AutoSplitKey = true;
    Caption = 'GIM - Mapping 2';
    DataCaptionFields = "Document No.","Doc. Type Code","Sender ID","Version No.";
    PageType = List;
    SourceTable = "GIM - Mapping Table Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = "Buffer Indentation Level";
                IndentationControls = "Table Caption";
                field("Table ID";"Table ID")
                {
                }
                field("Table Caption";"Table Caption")
                {
                    Editable = false;
                }
                field(Priority;Priority)
                {
                }
                field("Find Record";"Find Record")
                {
                }
                field("If Found";"If Found")
                {
                }
                field("If Not Found";"If Not Found")
                {
                }
                field("Data Action";"Data Action")
                {
                }
                field(Note;Note)
                {
                }
            }
            part(Control6150617;"GIM - Map. Table Field Filters")
            {
                SubPageLink = "Document No."=FIELD("Document No."),
                              "Doc. Type Code"=FIELD("Doc. Type Code"),
                              "Sender ID"=FIELD("Sender ID"),
                              "Version No."=FIELD("Version No."),
                              "Mapping Table Line No."=FIELD("Line No.");
                Visible = "Find Record";
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Fields")
            {
                Caption = 'Fields';
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ShowFields();
                end;
            }
            action(DecLevel)
            {
                Caption = 'Decrement Level';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ChangeIndentationLevel(false);
                end;
            }
            action(IncLevel)
            {
                Caption = 'Increment Level';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ChangeIndentationLevel(true);
                end;
            }
            action(Reset)
            {
                Caption = 'Reset';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ResetMapping();
                end;
            }
            action(SelectVersion)
            {
                Caption = 'Select Version';
                Image = SelectLineToApply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    SelectVersion(true,"Document No.","Doc. Type Code","Sender ID","Version No.");
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        if "Document No." <> '' then
          CheckVersionAndPrompt();
    end;
}


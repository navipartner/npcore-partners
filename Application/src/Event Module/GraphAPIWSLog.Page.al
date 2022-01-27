page 6014665 "NPR GraphAPI WS Log"
{
    Extensible = False;

    ApplicationArea = NPRRetail;
    Caption = 'GraphAPI WS Log';
    PageType = List;
    SourceTable = "NPR GraphAPI WS Log";
    UsageCategory = History;
    SourceTableView = sorting("Call No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Call No."; Rec."Call No.")
                {
                    ToolTip = 'Specifies the value of the Call No field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Call Description"; Rec."Call Description")
                {
                    ToolTip = 'Specifies the value of the Call Description field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Call Date Time"; Rec."Call Date Time")
                {
                    ToolTip = 'Specifies the value of the Call Date Time field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Call URL"; Rec."Call URL")
                {
                    ToolTip = 'Specifies the value of the Call URL field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the value of the E-Mail field.';
                    ApplicationArea = NPRRetail;
                }
                field("Call Request"; Rec.GetCallRequest())
                {
                    Caption = 'Call Request';
                    ToolTip = 'Specifies the value of the Call Request field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field("Call Response"; Rec.GetCallResponse())
                {
                    Caption = 'Call Response';
                    ToolTip = 'Specifies the value of the Call Response field.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
            }
        }
    }

}

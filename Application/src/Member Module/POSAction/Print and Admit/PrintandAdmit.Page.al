page 6184938 "NPR Print and Admit"
{
    Extensible = false;
    Caption = 'Print and Admit';
    PageType = List;
    SourceTable = "NPR Print and Admit Buffer";
    SourceTableTemporary = true;
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec."Type")
                {
                    ToolTip = 'Specifies the type of data.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Visual Id"; Rec."Visual Id")
                {
                    ToolTip = 'Specifies the identification of the record. Like Ticket number, Member card number or Token';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field(Print; Rec.Print)
                {
                    ToolTip = 'Specifies if the entry should be printed.';
                    ApplicationArea = NPRRetail;
                }
                field(Admit; Rec.Admit)
                {
                    ToolTip = 'Specifies if the entry should be admitted.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetTable(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        Rec.Copy(PrintandAdmitBuffer, true);
    end;

    internal procedure GetTable(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
        PrintandAdmitBuffer.Copy(Rec, true);
    end;
}

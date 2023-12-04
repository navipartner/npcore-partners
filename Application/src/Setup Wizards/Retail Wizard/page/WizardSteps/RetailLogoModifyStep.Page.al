page 6150789 "NPR Retail Logo Modify Step"
{
    Caption = 'Retail Logo Setup';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/retail_logo/';
    Extensible = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR Retail Logo";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            usercontrol("NPR ResizeImage"; "NPR ResizeImage")
            {
                ApplicationArea = NPRRetail;

                trigger OnCtrlReady()
                begin
                    RetailLogoMgtCtrl.InitializeResizeImage(CurrPage."NPR ResizeImage");
                end;

                trigger returnImage(resizedImage: Text; escpos: Text; Hi: Integer; Lo: Integer; CmdHi: Integer; CmdLo: Integer)
                var
                    RetailLogo: Record "NPR Retail Logo";
                begin
                    RetailLogoMgtCtrl.CreateRecord(RetailLogo, resizedImage, escpos, Hi, Lo, CmdHi, CmdLo);
                end;
            }
            repeater(Group)
            {
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the order or priority of the retail logo';
                }
                field(Keyword; Rec.Keyword)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the keyword used to display the logo in a Retail Print Template.';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the POS unit code associated with the retail logo.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the first date on which the retail logo will be displayed.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the last date on which the retail logo will be displayed.';
                }
                field("Boca Compatible"; Rec.OneBitLogo.HasValue())
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Boca Compatible';
                    Editable = false;
                    ToolTip = 'Specifies if the logo is compatible with Boca printers.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import Logo")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Import Logo';
                Image = Picture;
                ToolTip = 'Import an image file to use as a logo.';

                trigger OnAction()
                begin
                    RetailLogoMgtCtrl.UploadLogo();
                end;
            }
            action("Show Logo")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Logo';
                Image = View;
                ToolTip = 'Show an image file to use as a logo.';

                trigger OnAction()
                var
                    RetailLogoFactbox: Page "NPR Retail Logo Factbox";
                begin
                    RetailLogoFactbox.SetRecord(Rec);
                    RetailLogoFactbox.RunModal();
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        RetailLogo: Record "NPR Retail Logo";
    begin
        if RetailLogo.Get(Rec.Sequence) then
            RetailLogo.Delete();
    end;

    var
        RetailLogoMgtCtrl: Codeunit "NPR Retail Logo Mgt.";

    internal procedure CreateRetailLogoBuffer(var TempPOSUnit: Record "NPR POS Unit")
    var
        LastSequenceNo: Integer;
        I: Integer;
    begin
        I := 1;
        if TempPOSUnit.IsEmpty() then
            exit;

        if not Rec.IsEmpty() then
            Rec.DeleteAll();

        LastSequenceNo := GetLastSequenceNo();

        TempPOSUnit.FindSet();
        repeat
            Rec.Init();
            if I = 1 then begin
                Rec.Sequence := LastSequenceNo;
                I += 1;
            end else
                Rec.Sequence := Rec.Sequence + 1;
            Rec."Register No." := TempPOSUnit."No.";
            Rec.Insert();
        until TempPOSUnit.Next() = 0;
    end;

    internal procedure DeleteRetailLogoData()
    var
        RetailLogo: Record "NPR Retail Logo";
    begin
        if Rec.IsEmpty() then
            exit;

        Rec.FindSet();
        repeat
            if RetailLogo.Get(Rec.Sequence) then
                RetailLogo.Delete();
        until Rec.Next() = 0;
    end;

    internal procedure RetailLogosToCreate(): Boolean
    var
        RetailLogo: Record "NPR Retail Logo";
    begin
        if Rec.IsEmpty() then
            exit(false);

        Rec.FindSet();
        repeat
            if RetailLogo.Get(Rec.Sequence) then
                exit(true);
        until Rec.Next() = 0;
    end;

    local procedure GetLastSequenceNo(): Integer
    var
        RetailLogo: Record "NPR Retail Logo";
    begin
        if RetailLogo.FindLast() then
            exit(RetailLogo.Sequence + 1)
        else
            exit(1);
    end;
}
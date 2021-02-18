codeunit 6014424 "NPR Receipt Footer Mgt."
{
    procedure GetPOSUnitTicketText(var RetailComment: Record "NPR Retail Comment" temporary; POSUnit: Record "NPR POS Unit")
    var
        RetailComment2: Record "NPR Retail Comment";
        POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile";
    begin
        if not POSUnitReceiptTextProfile.Get(POSUnit."POS Unit Receipt Text Profile") then
            exit;
        RetailComment.DeleteAll;
        case POSUnitReceiptTextProfile."Sales Ticket Line Text off" of
            POSUnitReceiptTextProfile."Sales Ticket Line Text off"::Comment:
                begin
                    RetailComment2.SetRange("Table ID", DATABASE::"NPR POS Unit");
                    RetailComment2.SetRange("No.", POSUnit."POS Unit Receipt Text Profile");
                    RetailComment2.SetRange(Integer, 1000);
                    RetailComment2.SetRange("Hide on printout", false);
                    if RetailComment2.FindSet then begin
                        repeat
                            RetailComment.Init;
                            RetailComment := RetailComment2;
                            RetailComment.Insert;
                        until (RetailComment2.Next = 0);
                    end;
                end;

            POSUnitReceiptTextProfile."Sales Ticket Line Text off"::"Pos Unit":
                begin
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text1" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text1";
                        RetailComment."Line No." := 1000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text2" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text2";
                        RetailComment."Line No." := 2000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text3" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text3";
                        RetailComment."Line No." := 3000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text4" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text4";
                        RetailComment."Line No." := 4000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text5" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text5";
                        RetailComment."Line No." := 5000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text6" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text6";
                        RetailComment."Line No." := 6000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text7" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text7";
                        RetailComment."Line No." := 7000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text8" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text8";
                        RetailComment."Line No." := 8000;
                        RetailComment.Insert;
                    end;
                    if POSUnitReceiptTextProfile."Sales Ticket Line Text9" <> '' then begin
                        RetailComment.Init;
                        RetailComment.Comment := POSUnitReceiptTextProfile."Sales Ticket Line Text9";
                        RetailComment."Line No." := 9000;
                        RetailComment.Insert;
                    end;
                end;
        end;
    end;
}


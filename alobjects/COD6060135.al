// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6060135 "MM Member POS UI"
{
    // MM1.14/TSA/20160603  CASE 240749 Transport MM1.13 - 1 June 2016
    // MM1.15/TSA/20160817  CASE 244443 Transport MM1.15 - 19 July 2016
    // MM1.16/TSA/20160908 CASE 251175 Adding support for facial recognition
    // MM1.32/TSA /20180713 CASE 321176 Added a new template for selecting a coupon


    var
        Marshaller: Codeunit "POS Event Marshaller";
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        POINTS_TO_DEDUCT: Label 'Points to Deduct';
        DISCOUNT_AMOUNT: Label 'Discount';

    procedure SearchBox(Title: Text; Caption: Text; MaxStringLength: Integer) ScannedValue: Text
    begin

        //ScannedValue := Marshaller.SearchBox (Title, Caption);
        ScannedValue := Marshaller.SearchBox(Title, Caption, MaxStringLength);
        if (ScannedValue = '<CANCEL>') then
            Error('');

        if (StrLen(ScannedValue) > MaxStringLength) then
            Error(ILLEGAL_VALUE, ScannedValue, Title);

        exit(ScannedValue);
    end;

    procedure DoLookup(LookupCaption: Text; LookupRecRef: RecordRef) Position: Text
    var
        Template: DotNet npNetTemplate;
    begin

        ConfigureLookupTemplate(Template, LookupRecRef);
        Position := Marshaller.Lookup(LookupCaption, Template, LookupRecRef, false, false, 0);
    end;

    local procedure ConfigureLookupTemplate(var Template: DotNet npNetTemplate; LookupRec: RecordRef)
    var
        Vendor: Record Vendor;
        ItemGroup: Record "Item Group";
        SaleLinePOS: Record "Sale Line POS";
        Row: DotNet npNetRow;
        Info: DotNet npNetInfo;
        TextAlign: DotNet npNetTextAlign;
        NumberFormat: DotNet npNetNumberFormat;
    begin
        Template := Template.Template();

        case LookupRec.Number of
            DATABASE::Item:
                begin
                    Template.Class := 'item';
                    Template.ValueFieldId := 1;

                    Row := Row.Row();
                    Row.AddInfo('no', LookupRec.Field(1).Caption, 1, TextAlign.Left, 16, 'calc(25% - 2px)', NumberFormat.None, true);
                    Info := Row.AddInfo('category', ItemGroup.TableCaption, 6014400, TextAlign.Left, 16, 'calc(25% - 3px)', NumberFormat.None, false);
                    Info.RelatedTableFieldNo := 2;
                    Info := Row.AddInfo('vendor', Vendor.TableCaption, 31, TextAlign.Left, 16, 'calc(25% - 3px)', NumberFormat.None, false);
                    Info.RelatedTableFieldNo := 2;
                    Row.AddInfo('inventory', LookupRec.Field(68).Caption, 68, TextAlign.Right, 16, 'calc(25% - 2px)', NumberFormat.Integer, false);
                    Template.Rows.Add(Row);

                    Row := Row.Row();
                    Row.AddInfo('description', '', 3, TextAlign.Left, 32, '80%', NumberFormat.None, true);
                    Row.AddInfo('price', LookupRec.Field(18).Caption, 18, TextAlign.Right, 24, 'calc(20% - 6px)', NumberFormat.Number, false);
                    Template.Rows.Add(Row);
                end;

            DATABASE::"Retail List":
                begin
                    Template.Class := 'retail-list';
                    Template.ValueFieldId := 10;

                    Row := Row.Row();
                    Row.AddInfo('code', SaleLinePOS.FieldCaption("No."), 10, TextAlign.Left, 12, '', NumberFormat.None, true);
                    Template.Rows.Add(Row);

                    Row := Row.Row();
                    Row.AddInfo('caption', '', 2, TextAlign.Left, 32, '', NumberFormat.None, true);
                    Template.Rows.Add(Row);
                end;

            DATABASE::"MM Membership Entry":
                begin
                    Template.Class := 'change-membership-options';
                    Template.ValueFieldId := 20;

                    Row := Row.Row();
                    Row.AddInfo('itemno', LookupRec.Field(20).Caption, 20, TextAlign.Left, 16, 'calc(25% - 2px)', NumberFormat.None, true);
                    Row.AddInfo('fromdate', LookupRec.Field(10).Caption, 10, TextAlign.Left, 16, 'calc(25% - 2px)', NumberFormat.None, false);
                    Row.AddInfo('untildate', LookupRec.Field(11).Caption, 11, TextAlign.Left, 16, 'calc(25% - 2px)', NumberFormat.None, false);
                    Row.AddInfo('unitprice', LookupRec.Field(50).Caption, 50, TextAlign.Left, 16, 'calc(25% - 2px)', NumberFormat.None, false);
                    Template.Rows.Add(Row);

                    Row := Row.Row();
                    Row.AddInfo('description', LookupRec.Field(22).Caption, 22, TextAlign.Left, 32, '80%', NumberFormat.None, true);
                    Row.AddInfo('price', LookupRec.Field(51).Caption, 52, TextAlign.Left, 32, 'calc(20% - 2px)', NumberFormat.None, true);
                    Template.Rows.Add(Row);
                end;

                //-MM1.32 [321176]
            DATABASE::"MM Loyalty Points Setup":
                begin
                    Template.Class := 'view-available-coupons';
                    Template.ValueFieldId := 30;

                    Row := Row.Row();
                    Row.AddInfo('code', LookupRec.Field(30).Caption, 30, TextAlign.Left, 16, '20%', NumberFormat.None, true);
                    Row.AddInfo('points', POINTS_TO_DEDUCT, 20, TextAlign.Left, 16, '20%', NumberFormat.None, true);
                    Row.AddInfo('dscpct', LookupRec.Field(1020).Caption, 1020, TextAlign.Left, 16, '20%', NumberFormat.None, true);
                    Row.AddInfo('dscamt', LookupRec.Field(1025).Caption, 1025, TextAlign.Left, 16, '20%', NumberFormat.None, true);

                    Template.Rows.Add(Row);

                    Row := Row.Row();
                    Row.AddInfo('description', LookupRec.Field(10).Caption, 10, TextAlign.Left, 32, '80%', NumberFormat.None, true);
                    Row.AddInfo('value', DISCOUNT_AMOUNT, 21, TextAlign.Left, 32, 'calc(20% - 2px)', NumberFormat.None, true);
                    Template.Rows.Add(Row);

                end;
                //+MM1.32 [321176]

        end;
    end;

    procedure MemberSearchWithFacialRecognition(var MemberEntryNo: Integer) MemberFound: Boolean
    var
        MCSWebcamAPI: Codeunit "MCS Webcam API";
        Member: Record "MM Member";
        RecRef: RecordRef;
        FRec: FieldRef;
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
        MCSWebcamArgumentTable: Record "MCS Webcam Argument Table";
    begin

        MemberEntryNo := 0;

        if not (MCSWebcamAPI.CallIdentifyStart(Member, MCSWebcamArgumentTable, false)) then
            exit(false);

        if not (MCSPersonBusinessEntities.Get(MCSWebcamArgumentTable."Person Id", DATABASE::"MM Member")) then
            exit(false);

        RecRef.Get(MCSWebcamArgumentTable.Key);
        FRec := RecRef.Field(1);
        Member.Get(FRec.Value);
        MemberEntryNo := Member."Entry No.";

        exit(true);
    end;
}


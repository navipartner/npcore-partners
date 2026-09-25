codeunit 6151127 "NPR NPRE View Setup Version"
{
    Access = Internal;

    // Builds the token the POS restaurant view uses to tell whether the static layout it is holding is still current.
    //
    // The token has to move whenever anything the layout payload is assembled from moves, and stay put when only
    // operational state changes: a table changing status or a waiter pad opening and closing must not cost a full
    // reload, because that is the reload this whole exercise exists to avoid.
    //
    // It also has to differ between restaurants. The payload's rooms and components are scoped to one restaurant, so a
    // token that did not name it would let a front end quote the token it was given for restaurant A while asking for
    // restaurant B, match, and keep A's floor plan under B's tables.
    //
    // Each part is built from what the payload actually carries rather than from a stamp that stands in for it. A
    // modified stamp moves for reasons the payload never shows, and a count plus a maximum cannot tell one set of rows
    // from another of the same size.

    internal procedure Calculate(RestaurantCode: Code[20]; var TempRestaurant: Record "NPR NPRE Restaurant" temporary; StatusSetupRowCount: Integer; StatusSetupLastModifiedAt: DateTime) Version: Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        SeatingSetupLastModifiedAt: DateTime;
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        RestaurantList: Text;
        RestaurantEntryTok: Label '%1=%2;', Locked = true;
        VersionFormatTok: Label '%1|%2|%3|%4:%5', Locked = true;
    begin
        // Read straight off the temporary copies. Learn, Table System fields: "If a record is copied into a temporary
        // table, the data audit field values are copied as well. The values aren't changed by the server when calling a
        // modify or insert method." The caller built this list moments ago from live rows, so re-reading each one would
        // be a round trip per restaurant for values already in hand.
        //
        // The caller is finished with the list by the time it gets here, so moving its position is harmless, and any
        // filter it carries is the scope the payload was built for.
        if TempRestaurant.FindSet() then
            repeat
                // Built from exactly what the payload shows for a restaurant, its code and its name, rather than from
                // the row's modified stamp. The stamp looked like a cheaper proxy and is not: the subscriber that
                // records a seating change writes the restaurant row, so it moves that restaurant's SystemModifiedAt
                // too, and any stamp taken across the switch list would put restaurant B's floor plan edits back into
                // restaurant A's token. Listing codes and names also catches the cases a count and a maximum cannot:
                // a switch filter changing from A|B to A|C leaves both unchanged while the list the operator can pick
                // from is different.
                RestaurantList += StrSubstNo(RestaurantEntryTok, TempRestaurant.Code, TempRestaurant.Name);

                // The seating setup stamp covers rooms, tables and layout components. Only one restaurant's are in the
                // payload when the caller named one, so taking the maximum across all of them would reload restaurant
                // A's floor plan every time somebody edited restaurant B.
                if (RestaurantCode = '') or (TempRestaurant.Code = RestaurantCode) then
                    Accumulate(SeatingSetupLastModifiedAt, TempRestaurant."Seating Setup Last Modified At");
            until TempRestaurant.Next() = 0;

        // Hashed so the token stays a fixed length whatever the list costs. It travels to the front end and back on
        // every update, and a chain with a long switch list would otherwise carry every code and name both ways.
        exit(
            StrSubstNo(
                VersionFormatTok,
                RestaurantCode,
                CryptographyManagement.GenerateHash(RestaurantList, HashAlgorithmType::MD5),
                Format(SeatingSetupLastModifiedAt, 0, 9),
                StatusSetupRowCount, Format(StatusSetupLastModifiedAt, 0, 9)));
    end;

    local procedure Accumulate(var LastModifiedAt: DateTime; Candidate: DateTime)
    begin
        if Candidate > LastModifiedAt then
            LastModifiedAt := Candidate;
    end;
}

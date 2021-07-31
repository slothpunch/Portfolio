/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT 
    saledate, 
    CONVERT(STR_TO_DATE(SaleDate, '%M %d, %Y'), DATE)
FROM
    nashville_housing;

COMMIT;

UPDATE nashville_housing
SET saledate = STR_TO_DATE(SaleDate, '%M %d, %Y');

SELECT saledate
FROM nashville_housing;

COMMIT;

------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress data
SELECT COUNT(*)
FROM nashville_housing;

SELECT 
	a.UniqueID,
	a.ParcelID,
    a.PropertyAddress,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a, nashville_housing b
WHERE a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
	AND a.PropertyAddress IS NULL
ORDER BY a.UniqueID;

UPDATE nashville_housing A
        INNER JOIN
    nashville_housing B ON A.ParcelID = B.ParcelID 
SET 
    A.PropertyAddress = B.PropertyAddress
WHERE
    A.UniqueID <> B.UniqueID
        AND A.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- 		1808 FOX CHASE DR, GOODLETTSVILLE
-- 		Address     		 City 			 
-- 		1808 FOX CHASE DR	 GOODLETTSVILLE
--

SELECT *
FROM nashville_housing;

SELECT 
-- 	PropertyAddress,
    SUBSTR(PropertyAddress, 1, LOCATE(',', PropertyAddress, 1)-1) AS Address,
    SUBSTR(PropertyAddress, LOCATE(',', PropertyAddress)+1),
    SUBSTR(PropertyAddress, POSITION(',' IN PropertyAddress)+1)
FROM
    nashville_housing;

COMMIT;

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitAddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitCity VARCHAR(255);

SELECT * FROM nashville_housing;

COMMIT;

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, LOCATE(',', PropertyAddress, 1)-1);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTR(PropertyAddress, LOCATE(',', PropertyAddress)+1);

-- OwnerAddress

SELECT OwnerAddress
FROM nashville_housing;

SELECT 
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    REPLACE(REPLACE(SUBSTRING_INDEX(OwnerAddress, ',', 2), SUBSTRING_INDEX(OwnerAddress, ',', 1), ''), ', ', '') AS City,
    REPLACE(SUBSTRING_INDEX(OwnerAddress, ',', -1), ' ', '') AS State
FROM nashville_housing;

-- Create columns 

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitCity VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitState VARCHAR(255);

COMMIT;

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE nashville_housing
SET OwnerSplitCity = REPLACE(REPLACE(SUBSTRING_INDEX(OwnerAddress, ',', 2), SUBSTRING_INDEX(OwnerAddress, ',', 1), ''), ', ', '');

UPDATE nashville_housing
SET OwnerSplitState = REPLACE(SUBSTRING_INDEX(OwnerAddress, ',', -1), ' ', '');


SELECT * FROM nashville_housing;

SELECT 
	OwnerAddress,
    OwnerSplitAddress,
    OwnerSplitCity,
    OwnerSplitState
FROM nashville_housing;


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant
FROM nashville_housing;

SELECT 
	DISTINCT(SoldAsVacant), 
    COUNT(SoldAsVacant)
FROM 
	nashville_housing
GROUP BY SoldAsVacant;

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    ELSE SoldAsVacant
END
FROM nashville_housing
WHERE SoldAsVacant IN ('N','Y');

COMMIT;
ROLLBACK;

UPDATE nashville_housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    ELSE SoldAsVacant
END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT ParcelID, COUNT(ParcelID), PropertyAddress, SaleDate, SalePrice, LegalReference
FROM nashville_housing
GROUP BY ParcelID
HAVING COUNT(ParcelID) > 1
ORDER BY COUNT(ParcelID) DESC;

SELECT *, 
	ROW_NUMBER() OVER(
    PARTITION BY ParcelID, 
				PropertyAddress, 
                SaleDate, 
                SalePrice, 
                LegalReference 
                ORDER BY ParcelID) row_num
FROM nashville_housing;

SELECT *
FROM nashville_housing
WHERE ParcelID = '081 02 0 144.00';

-- Create a CTE
WITH rownumcte AS(
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY ParcelID, 
				PropertyAddress, 
                SaleDate, 
                SalePrice, 
                LegalReference 
                ORDER BY ParcelID) row_num
FROM nashville_housing
) SELECT *
FROM rownumcte
WHERE row_num > 1
ORDER BY ParcelID;

COMMIT;

ALTER TABLE nashville_housing
ADD COLUMN row_num NUMERIC;

SELECT * FROM nashville_housing;

COMMIT;

WITH rownumcte AS(
SELECT UniqueID, ROW_NUMBER() OVER(
    PARTITION BY ParcelID, 
				PropertyAddress, 
                SaleDate, 
                SalePrice, 
                LegalReference 
                ORDER BY ParcelID) rownum
FROM nashville_housing
) UPDATE nashville_housing a
INNER JOIN rownumcte b
ON a.UniqueID = b.UniqueID
SET a.row_num = b.rownum;

SELECT 
    *
FROM
    nashville_housing
WHERE
    row_num > 1;

COMMIT;

DELETE FROM nashville_housing
WHERE row_num > 1;

ROLLBACK;
-- Delete the duplicates ------ NOT WOKRING

WITH rownumcte AS(
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY ParcelID, 
				PropertyAddress, 
                SaleDate, 
                SalePrice, 
                LegalReference 
                ORDER BY ParcelID) row_num
FROM nashville_housing
) DELETE FROM rownumcte
WHERE rownumcte.row_num > 1;


COMMIT;

ROLLBACK;

WITH rownumcte AS(
SELECT *, ROW_NUMBER() OVER(
    PARTITION BY ParcelID, 
				PropertyAddress, 
                SaleDate, 
                SalePrice, 
                LegalReference 
                ORDER BY ParcelID) row_num
FROM nashville_housing
) DELETE nashville_housing
FROM nashville_housing
INNER JOIN rownumcte
ON nashville_housing.ParcelID = rownumcte.ParcelID
WHERE row_num > 1; -- 233 


SELECT COUNT(*) FROM nashville_housing; -- 56477

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM nashville_housing;












-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


-- sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- GO
-- sp_configure 'Ad Hoc Distributed Queries', 1;
-- RECONFIGURE;
-- GO


-- USE PortfolioProject 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

-- GO 

-- EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

-- GO 


-- -- Using BULK INSERT

-- USE PortfolioProject;
-- GO
-- BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
-- );
-- GO


-- -- Using OPENROWSET
-- USE PortfolioProject;
-- GO
-- SELECT * INTO nashvilleHousing
-- FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
-- GO


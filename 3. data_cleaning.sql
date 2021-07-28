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

SELECT ParcelID, PropertyAddress, TNOwnerAddress
FROM nashville_housing
WHERE PropertyAddress != TNOwnerAddress; -- 5075
-- WHERE PropertyAddress IS NULL; -- 29
-- WHERE PropertyAddress = TNOwnerAddress; -- 20922
-- WHERE TNOwnerAddress IS NULL; -- 30462
-- WHERE PropertyAddress != OwnerAddress;

SELECT 
	ParcelID, 
	PropertyAddress, 
    REPLACE(OwnerAddress, ', TN', '') AS OwnerAddress
FROM nashville_housing
WHERE PropertyAddress != REPLACE(OwnerAddress, ', TN', '');


COMMIT;

ALTER TABLE nashville_housing
ADD COLUMN TNOwnerAddress TEXT AFTER PropertyAddress;

SELECT * FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN TNOwnerAddress;

ALTER TABLE nashville_housing
DROP COLUMN MyUnknownColumn;

SELECT * FROM nashville_housing;

UPDATE nashville_housing
SET TNOwnerAddress = REPLACE(OwnerAddress, ', TN', '');


SELECT 
	a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress
FROM nashville_housing a
JOIN nashville_housing b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

SELECT 
	a.UniqueID,
	a.ParcelID,
    a.PropertyAddress,
    b.UniqueID,
    b.ParcelID,
    b.PropertyAddress
FROM nashville_housing a
JOIN nashville_housing b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
ORDER BY a.UniqueID;

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL
ORDER BY UniqueID;

SELECT 
	a.ParcelID,
	a.PropertyAddress,
    REPLACE(a.OwnerAddress, ', TN', '') AS OwnerAddress
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
-- WHERE PropertyAddress = REPLACE(OwnerAddress, ', TN', '');

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates







---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns














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




--Cleaning Data in SQL Queries


--Standardize Date Format, Use both CONVERT and CAST Method

SELECT SaleDate, CONVERT(date,SaleDate) as SaleDateStandard
FROM HousingStudy

SELECT SaleDateStandard, CAST(SaleDate as date) as SaleDateStandard
FROM HousingStudy

ALTER TABLE HousingStudy
ADD SaleDateStandard date

UPDATE HousingStudy
SET SaleDateStandard = CAST(SaleDate as date)


--Populate Property Address data
--First we found the PropertyAddress column has null value
--Self join the same table find the same ParcelID with NULL in PropertyAddress
--The same ParcelID should have the same PropertyAddress if the UniqueID is different
--So I use ISNULL to find thoses NULL PropertyAddress and populate them with the correct Address
--Then update the table to populate the PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM HousingStudy as a
JOIN HousingStudy as b ON a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null	

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM HousingStudy a 
JOIN HousingStudy b ON a.ParcelID = b.ParcelID and a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null	

--Breaking Address apart into different columns(Address, City, State)
--First find the comma and get rid of it
SELECT PropertyAddress
FROM HousingStudy

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
FROM HousingStudy


-- USING PARSENAME TO Extract substrings from OwnerAddress
-- Separate address into Street, City, State
-- Then using ALTER TABLE to add Street, City, State Columns and update them with the split infomation
-- This action makes the data more useful. The address data is now much more useable compare just one column in Address

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) Street
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2) City
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) State
FROM HousingStudy

ALTER TABLE HousingStudy
ADD Street nvarchar(255)

UPDATE HousingStudy
SET Street = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE HousingStudy
ADD City nvarchar(255)

UPDATE HousingStudy
SET City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE HousingStudy
ADD State nvarchar(255)

UPDATE HousingStudy
SET State = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM HousingStudy


--Change Y and N to Yes and No in 'SoldAsVacant' column Using CASE WHEN 
--This process cleans data in SoldAsVacant column 

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM HousingStudy

UPDATE HousingStudy
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT SoldAsVacant	
FROM HousingStudy


--DELETE Columns
--DELETE PropertyAddress, OwnerAddress since we have split addresses which are more useable

ALTER TABLE HousingStudy
DROP Column PropertyAddress, OwnerAddress
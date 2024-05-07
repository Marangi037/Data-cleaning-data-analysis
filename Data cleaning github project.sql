select *
from Housing_Details

--Standardize date format
select CONVERT(date, SaleDate) as SaleDate
from Housing_Details
--The update query did not work so i added a column to the table and inserted the standardized dates in it

ALTER TABLE Housing_Details
ADD SaleDateConverted Date

UPDATE Housing_Details
SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate property address
UPDATE Housing_Details
SET PropertyAddress=REPLACE(PropertyAddress,'', NULL)

SELECT PropertyAddress
FROM Housing_Details
where PropertyAddress is null
order by ParcelID

--Self join

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(a.propertyAddress, b.PropertyAddress)
FROM Housing_Details a
JOIN Housing_Details b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress =  coalesce(a.propertyAddress, b.PropertyAddress)
FROM Housing_Details a
JOIN Housing_Details b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID

-- Returns no NULL values, shows that PropertyAddress has been updated
SELECT * 
FROM Housing_Details
WHERE PropertyAddress IS NULL


--Breaking out address into individual columns(Address, City)

-- USE SUBSTRING function to look at property address column at position one. Use CHARINDEX function to look 
-- for a specific string/char, in a particular column name, returning the char num  ',' is located at, 
-- so adding -1 at the end of the SUBSTRING function would take away the comma

select PropertyAddress
from Housing_Details

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Housing_Details

ALTER TABLE Housing_Details
ADD PropertysplitAddress nvarchar(255)


ALTER TABLE Housing_Details
ADD PropertysplitCity nvarchar(255)

UPDATE Housing_Details
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE Housing_Details
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Breaking down the owner address into individual columns (Address, City and State)
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '-') , 3) Address
,PARSENAME(REPLACE(OwnerAddress, ',', '-') ,2) City
,PARSENAME(REPLACE(OwnerAddress, ',', '-') ,1)State
FROM Housing_Details

ALTER TABLE Housing_Details
ADD OwnerSplitCity nvarchar(255)


ALTER TABLE Housing_Details
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE Housing_Details
ADD OwnerSplitState nvarchar(255)

UPDATE Housing_Details
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '-') , 3)


UPDATE Housing_Details
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '-') , 2)


UPDATE Housing_Details
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '-') , 1)

--Changing 'Y' and 'N' to yes or no on sold as vacant
SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
from Housing_Details
group by (SoldAsVacant)

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Housing_Details

UPDATE Housing_Details
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

	 --Removing duplicates
select *, ROW_NUMBER () OVER (PARTITION BY ParcelID, LandUse, SalePrice, LegalReference, SaleDateConverted order by UniqueID) as row_num
from Housing_Details

WITH rownumCTE as (select *, ROW_NUMBER () OVER (PARTITION BY ParcelID, LandUse, SalePrice, LegalReference, SaleDateConverted order by UniqueID) as row_num
from Housing_Details)

select *
from rownumCTE
where row_num > 1

--Deleting the duplicates

WITH rownumCTE as (select *, ROW_NUMBER () OVER (PARTITION BY ParcelID, LandUse, SalePrice, LegalReference, SaleDateConverted order by UniqueID) as row_num
from Housing_Details)

delete
from rownumCTE
where row_num > 1

--Delete unused columns 
ALTER TABLE Housing_Details
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxiDistrict

--Final data cleaning results
select *
from Housing_Details

/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProject..NashvilleHousing


-- Standardise Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

-- Here I am just checking column has been updated correctly.

SELECT * 
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------


-- Populate Property Address Data

SELECT * 
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

-- The below statement is to identify the occurences of null values in the PropertyAddress column
--By identifying them, the ParcelID column and the Unique ID column can be used to update the null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Update statement to replace null values
-- Below statement effectiveness can be checked by running previous statement

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyADdress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,  -- Return everything before the comma in PropertyAddress

SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1) as City  --Return everything after the comma in City

FROM PortfolioProject..NashvilleHousing

-- Now to update this into our table


ALTER TABLE Nashvillehousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE Nashvillehousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1)

SELECT  PropertySplitAddress , PropertySplitCity
FROM PortfolioProject..NashvilleHousing


-- Now to do the same for Owner address but with a different method


SELECT  OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



--------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END



--------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
				
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
Where row_num >1


--------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
--					CLEANING DATA PROJECT


SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]

-- 1.
-- Cambiar el formato de la fecha

SELECT SaleDate, CONVERT (date, SaleDate)
FROM PortfolioProject.dbo.[NashvilleHousing ]

--UPDATE [NashvilleHousing ]                             --this didn´t work so we use the option below, to add a new column
--Set SaleDate = CONVERT(date, SaleDate)				-- later on we will delete the original SaleDate column

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE [NashvilleHousing ]
Set SaleDateConverted = CONVERT(date, SaleDate)

select *
from [NashvilleHousing ]



--2.
--Populate Property Address data cells that have NULL values

---first we need to check is there are null values in the PropertyAddress column
SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.[NashvilleHousing ] as A
	JOIN PortfolioProject.dbo.[NashvilleHousing ] as B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.[NashvilleHousing ] as A
	JOIN PortfolioProject.dbo.[NashvilleHousing ] as B
	ON A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]



--3. 
-- Breaking out Address into individua columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.[NashvilleHousing ]
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1)) as Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1), LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.[NashvilleHousing ]


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE [NashvilleHousing ]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1))


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(200);

UPDATE [NashvilleHousing ]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ]



--4. 
-- Breaking out OwnerAddress into individual columns (address, city, state)


SELECT OwnerAddress
FROM PortfolioProject.dbo.[NashvilleHousing ]


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.[NashvilleHousing ]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(50)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE [NashvilleHousing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [NashvilleHousing ]



--5.
-- Changing Y and N in the 'SoldAsVacant' column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT REPLACE(SoldAsVacant, 'Y', 'Yes')
FROM [NashvilleHousing ]



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [NashvilleHousing ]

UPDATE [NashvilleHousing ]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



--6.
--Remove Duplicates

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
FROM PortfolioProject.dbo.[NashvilleHousing ]
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

-- After finding the duplicates we will delete them

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
FROM PortfolioProject.dbo.[NashvilleHousing ]
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num >1


--7. 
--DELETING UNUSED COLUMNS

SELECT*
FROM [NashvilleHousing ]

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __QCOM_MDT_LOADER_H__
#define __QCOM_MDT_LOADER_H__

#include <linux/types.h>

#define QCOM_MDT_TYPE_MASK	(7 << 24)
#define QCOM_MDT_TYPE_HASH	(2 << 24)
#define QCOM_MDT_RELOCATABLE	BIT(27)
#define QCOM_MDT_ASID_MASK      0xfu
#define QCOM_MDT_PF_ASID_SHIFT  16
#define QCOM_MDT_PF_ASID_MASK   (QCOM_MDT_ASID_MASK << QCOM_MDT_PF_ASID_SHIFT)
#define QCOM_MDT_PF_ASID(x)     \
			(((x) >> QCOM_MDT_PF_ASID_SHIFT) & QCOM_MDT_ASID_MASK)

struct device;
struct firmware;
struct qcom_scm_pas_metadata;

#if IS_ENABLED(CONFIG_QCOM_MDT_LOADER)

ssize_t qcom_mdt_get_size(const struct firmware *fw);
ssize_t qcom_mdt_get_file_size(const struct firmware *fw);
int qcom_mdt_pas_init(struct device *dev, const struct firmware *fw,
		      const char *fw_name, int pas_id, phys_addr_t mem_phys,
		      struct qcom_scm_pas_metadata *pas_metadata_ctx);
int qcom_mdt_load(struct device *dev, const struct firmware *fw,
		  const char *fw_name, int pas_id, void *mem_region,
		  phys_addr_t mem_phys, size_t mem_size,
		  phys_addr_t *reloc_base);

int qcom_mdt_load_no_init(struct device *dev, const struct firmware *fw,
			  const char *fw_name, int pas_id, void *mem_region,
			  phys_addr_t mem_phys, size_t mem_size,
			  phys_addr_t *reloc_base);
int qcom_mdt_load_pd_seg(struct device *dev, const struct firmware *fw,
			 const char *firmware, int pas_id, void *mem_region,
			 phys_addr_t mem_phys, size_t mem_size,
			 phys_addr_t *reloc_base);
void *qcom_mdt_read_metadata(const struct firmware *fw, size_t *data_len,
			     const char *fw_name, struct device *dev);
bool mdt_phdr_valid(const struct elf32_phdr *phdr);
#else /* !IS_ENABLED(CONFIG_QCOM_MDT_LOADER) */

static inline ssize_t qcom_mdt_get_size(const struct firmware *fw)
{
	return -ENODEV;
}

static inline int qcom_mdt_pas_init(struct device *dev, const struct firmware *fw,
				    const char *fw_name, int pas_id, phys_addr_t mem_phys,
				    struct qcom_scm_pas_metadata *pas_metadata_ctx)
{
	return -ENODEV;
}

static inline int qcom_mdt_load(struct device *dev, const struct firmware *fw,
				const char *fw_name, int pas_id,
				void *mem_region, phys_addr_t mem_phys,
				size_t mem_size, phys_addr_t *reloc_base)
{
	return -ENODEV;
}

static inline int qcom_mdt_load_no_init(struct device *dev,
					const struct firmware *fw,
					const char *fw_name, int pas_id,
					void *mem_region, phys_addr_t mem_phys,
					size_t mem_size,
					phys_addr_t *reloc_base)
{
	return -ENODEV;
}

static inline int qcom_mdt_load_pd_seg(struct device *dev,
				       const struct firmware *fw,
				       const char *fw_name, int pas_id,
				       void *mem_region, phys_addr_t mem_phys,
				       size_t mem_size,
				       phys_addr_t *reloc_base)
{
	return -ENODEV;
}

static inline void *qcom_mdt_read_metadata(const struct firmware *fw,
					   size_t *data_len, const char *fw_name,
					   struct device *dev)
{
	return ERR_PTR(-ENODEV);
}

static inline bool mdt_phdr_valid(const struct elf32_phdr *phdr)
{
	return false;
}
#endif /* !IS_ENABLED(CONFIG_QCOM_MDT_LOADER) */

#endif
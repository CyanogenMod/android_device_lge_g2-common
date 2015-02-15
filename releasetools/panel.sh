#!/sbin/sh
#
# 4.4 and beyond Kernel - Panel Detection - dr87 & Rashed97
#
# Detect panel and swap as necessary 
# lcd_maker_id is determined by get_panel_maker_id on the hardware and is always accurate
# This searches directly in the boot.img and has no other requirements
# Do not shorten the search or you may change the actual kernel source
#
#	LCD_RENESAS_LGD = 0,
#	LCD_RENESAS_JDI = 1
#
# Some ROMs will place boot.img in /tmp instead of /tmp/loki
# so support finding boot.img both locations
#
blcheck=$(grep -c "mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2" /proc/cmdline)
lcdmaker=$(grep -c "lcd_maker_id=1" /proc/cmdline)
if [ $blcheck == 1 ]; then
	echo "Command line panel attribute detected. No need to edit boot.img"
elif [ $blcheck == 0 ]; then
	echo "Command line panel attribute not found. Editing boot.img"
	if [ $lcdmaker == 1 ]; then
		echo "JDI panel detected"
		find /tmp/loki/boot.img -type f -exec sed -i 's/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_lgd_cmd/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_jdi_cmd/g' {} \;
		find /tmp/boot.img -type f -exec sed -i 's/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_lgd_cmd/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_jdi_cmd/g' {} \;
	elif [ $lcdmaker == "0" ]; then
		echo "LGD panel detected"
		find /tmp/loki/boot.img -type f -exec sed -i 's/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_jdi_cmd/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_lgd_cmd/g' {} \;
		find /tmp/boot.img -type f -exec sed -i 's/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_jdi_cmd/mdss_mdp.panel=1:dsi:0:qcom,mdss_dsi_g2_lgd_cmd/g' {} \;
	else
		echo "lcd_maker_id doesn't exist. Something went wrong."
	fi
else
	echo "cmdline doesn't exist. Something went wrong."
fi

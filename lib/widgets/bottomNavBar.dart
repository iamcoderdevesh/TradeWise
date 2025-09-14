import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/state/appState.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentSelectedIndex = appState.pageIndex;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        onTap: (index) => {
          setState(() {
            appState.setPageIndex = index;
          })
        },
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.blue.shade700,
        selectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              homeIcon,
              height: 26,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.string(
              height: 26,
              homeIcon,
              colorFilter: ColorFilter.mode(
                Colors.blue.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              height: 26,
              marketIcon,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.string(
              height: 26,
              marketIcon,
              colorFilter: ColorFilter.mode(
                Colors.blue.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Market",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              height: 26,
              portfolioIcon,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.string(
              height: 26,
              portfolioIcon,
              colorFilter: ColorFilter.mode(
                Colors.blue.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Portfolio",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              height: 26,
              userIcon,
              colorFilter: const ColorFilter.mode(
                inActiveIconColor,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.string(
              height: 26,
              userIcon,
              colorFilter: ColorFilter.mode(
                Colors.blue.shade700,
                BlendMode.srcIn,
              ),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

const homeIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="1200px" height="800px" viewBox="0 0 24 24" fill="none">
<rect width="32" height="24" fill="none"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M20.0005 10.5981C19.997 12.754 20.0003 14.9099 20.0003 17.0658C20.0004 17.9523 20.0004 18.7161 19.9182 19.3278C19.83 19.9833 19.6313 20.6116 19.1216 21.1213C18.612 21.6309 17.9836 21.8297 17.3281 21.9178C16.7164 22.0001 15.9526 22 15.0661 22L8.9345 22C8.048 22 7.28418 22.0001 6.67252 21.9178C6.017 21.8297 5.38865 21.6309 4.87899 21.1213C4.36932 20.6116 4.17058 19.9833 4.08245 19.3278C4.00021 18.7161 4.00026 17.9523 4.00031 17.0658C4.00031 14.9099 4.00364 12.754 4.00015 10.5981C3.99901 9.88495 3.99799 9.25177 4.25039 8.67295C4.5028 8.09413 4.96748 7.66402 5.49085 7.17961C6.54345 6.20534 7.59304 5.22779 8.64407 4.25182C9.25013 3.68899 9.77463 3.2019 10.249 2.86416C10.7587 2.50123 11.3189 2.22925 12.0003 2.22925C12.6817 2.22925 13.2419 2.50123 13.7516 2.86416C14.226 3.2019 14.7505 3.68899 15.3565 4.25182C16.4005 5.22133 17.4571 6.20529 18.5098 7.17961C19.0331 7.66403 19.4978 8.09413 19.7502 8.67295C20.0026 9.25177 20.0016 9.88496 20.0005 10.5981ZM12 16C11.4477 16 11 16.4477 11 17V19C11 19.5523 10.5523 20 10 20C9.44772 20 9 19.5523 9 19V17C9 15.3431 10.3431 14 12 14C13.6569 14 15 15.3431 15 17V19C15 19.5523 14.5523 20 14 20C13.4477 20 13 19.5523 13 19V17C13 16.4477 12.5523 16 12 16Z" fill="#323232"/>
</svg>''';

const marketIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="800px" height="800px" viewBox="0 0 24 24" fill="none">
<path d="M8 16V11M12 16V8M16 16V13M4 16.8L4 7.2C4 6.0799 4 5.51984 4.21799 5.09202C4.40973 4.7157 4.71569 4.40973 5.09202 4.21799C5.51984 4 6.0799 4 7.2 4H16.8C17.9201 4 18.4802 4 18.908 4.21799C19.2843 4.40973 19.5903 4.7157 19.782 5.09202C20 5.51984 20 6.0799 20 7.2V16.8C20 17.9201 20 18.4802 19.782 18.908C19.5903 19.2843 19.2843 19.5903 18.908 19.782C18.4802 20 17.9201 20 16.8 20H7.2C6.0799 20 5.51984 20 5.09202 19.782C4.71569 19.5903 4.40973 19.2843 4.21799 18.908C4 18.4802 4 17.9201 4 16.8Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

const portfolioIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="800px" height="800px" viewBox="0 0 24 24" fill="none">
<path d="M18 8V7.2C18 6.0799 18 5.51984 17.782 5.09202C17.5903 4.71569 17.2843 4.40973 16.908 4.21799C16.4802 4 15.9201 4 14.8 4H6.2C5.07989 4 4.51984 4 4.09202 4.21799C3.71569 4.40973 3.40973 4.71569 3.21799 5.09202C3 5.51984 3 6.0799 3 7.2V8M21 12H19C17.8954 12 17 12.8954 17 14C17 15.1046 17.8954 16 19 16H21M3 8V16.8C3 17.9201 3 18.4802 3.21799 18.908C3.40973 19.2843 3.71569 19.5903 4.09202 19.782C4.51984 20 5.07989 20 6.2 20H17.8C18.9201 20 19.4802 20 19.908 19.782C20.2843 19.5903 20.5903 19.2843 20.782 18.908C21 18.4802 21 17.9201 21 16.8V11.2C21 10.0799 21 9.51984 20.782 9.09202C20.5903 8.71569 20.2843 8.40973 19.908 8.21799C19.4802 8 18.9201 8 17.8 8H3Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

const userIcon =
    '''<svg xmlns="http://www.w3.org/2000/svg" width="800px" height="800px" viewBox="0 0 24 24" fill="none">
<path d="M5 21C5 17.134 8.13401 14 12 14C15.866 14 19 17.134 19 21M16 7C16 9.20914 14.2091 11 12 11C9.79086 11 8 9.20914 8 7C8 4.79086 9.79086 3 12 3C14.2091 3 16 4.79086 16 7Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''';

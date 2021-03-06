BUILD=build/
MK_BUILD=mkdir -p $(BUILD)
MJ_DIR=$(HOME)/.mujoco/mjpro150/
COMMON=-O2 -I$(MJ_DIR)/include -Iheaders -L$(MJ_DIR)/bin -mavx
H=800
W=800
RUN=ffmpeg -y -f rawvideo -pixel_format rgb24 -video_size $(H)x$(W) -framerate 60 -i $(BUILD)rgb.out -vf 'vflip' $(BUILD)video.mp4
PLAY=vlc $(BUILD)video.mp4

default:
	pip install -r requirements.txt
	python setup.py build_ext --inplace

# glfw and egl build a simple test example to ensure that the underlying c code works

osx:
	$(MK_BUILD)
	clang $(COMMON) src/utilGlfw.c -DMJ_GLFW src/util.c -lmujoco150 -lglfw.3 -o $(BUILD)utilosx
	$(BUILD)utilosx $(H) $(W)
	$(RUN)
	$(PLAY)

bug:
	$(MK_BUILD)
	clang $(COMMON) src/utilGlfw.c -DMJ_GLFW src/renderOffscreenBug.c -lmujoco150 -lglfw.3 -o $(BUILD)utilosx
	$(BUILD)utilosx $(H) $(W)

glfw:
	$(MK_BUILD)
	g++ $(COMMON) -std=c++11 src/utilGlfw.c -DMJ_GLFW src/util.c -lmujoco150 -lGL -lglew $(MJ_DIR)bin/libglfw.so.3 -o  $(BUILD)utilglfw
	$(BUILD)utilglfw $(H) $(W)
	$(RUN)

osmesa:
	$(MK_BUILD)
	g++ -g $(COMMON) -std=c++11 src/utilOsmesa.c -DMJ_OSMESA src/util.c -lmujoco150 -lOSMesa -lglewosmesa -o $(BUILD)utilosmesa
	$(BUILD)utilosmesa $(H) $(W)
	$(RUN)

egl:
	$(MK_BUILD)
	g++ $(COMMON) -g -std=c++11 -L/usr/lib/nvidia-390 -DMJ_EGL src/utilEgl.c src/util.c -lmujoco150 -lOpenGL -lEGL -lglewegl -o  $(BUILD)utilegl
	$(BUILD)utilegl $(H) $(W)
	$(RUN)

package:
	rm -rf dist/
	python setup.py bdist_wheel
	twine upload dist/*


clean:
	rm -f MUJOCO_LOG.txt
	rm -f egl/*.so
	rm -f glfw/*.so
	rm -f mujoco/*.so 
	rm -f mujoco/*.pyc
	rm -rf mujoco/__pycache__/ 
	rm -rf build/ 
	rm -rf *.egg-info 
	rm -rf dist/
